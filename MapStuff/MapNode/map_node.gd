extends Node2D
signal A_node_clicked(Name: String)
#var On_node: String = ""
var Has_building: bool = false
var building:Resource
@export var node_owner:String
@export var node_RPU: Resource
var unit_list:Array 
var fighter_resource:Resource=load("res://Resources/Preset/Fighter.tres")
var influence_resource:Resource=load("res://Resources/Preset/Influence.tres")
var base_resource:Resource=load("res://Resources/Preset/Miliary_Base.tres")
var unit_scene:PackedScene = load("res://MapStuff/Unit_Visual.tscn")
var flare_scene:PackedScene = load("res://GUI/Arrow/Arrow.tscn")
var dock_left:Texture = load("res://Assets/Map_Tiles/dock_left.png")
var dock_right:Texture = load("res://Assets/Map_Tiles/dock_right.png")
var Player_color:Vector3
enum{FIGHTER,INFLUENCE}
@onready var fade_material: ShaderMaterial = %Dock.material


func _ready() -> void:
	Overseer.Resources_to_rpc()
	Player_color = Overseer.Identify_player(multiplayer.get_unique_id()).color
	get_parent().find_child("Combat").combat_over.connect(_update_ui)
	Overseer.Received_node_data.connect(_update_ui)
	Overseer.Initialization_player_color.connect(Set_player_color)
	$Map_Node_Area2D.set_pickable(true) #sets-up the clickable area for the map nodes
	_randomize_sprites()
	if get_parent().name != "root":
		get_parent().update_label.connect(_update_label)
	for hexes:Node in get_parent().get_children():
		if hexes.is_in_group("RPU_Token"):
			if hexes.position.distance_squared_to(position) < 80000:
				node_RPU.RPU += hexes.rpu.RPU
				node_RPU.Population += hexes.rpu.Population
			else:
				pass
				#print(hexes.position.distance_squared_to(position))

func Set_player_color() -> void:
	Player_color = Overseer.Identify_player(multiplayer.get_unique_id()).color
	Overseer.Initialization_player_color.disconnect(Set_player_color) 

func _update_label()-> void:
	$Label.text = name

func _update_ui() -> void:
	var parent_node:Node  = get_parent()
	parent_node.find_child("Dynamic_Clicked").text = "Node " + name #probably should be replaced with a signal to UI instead of using find_child, ideally a universal update_UI(label, text) function to update any text in the UI.
	parent_node.find_child("Dynamic_RPU").text = str(node_RPU.RPU)
	parent_node.find_child("Dynamic_Pop").text = str(node_RPU.Population)
	parent_node.find_child("UI").update_node_unit_list(unit_list,name)

# Detects when Node is clicked on by mouse
func _on_map_node_area_2d_input_event(_viewport: Node,event: InputEvent,_shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and not event.pressed:
		#print("you have clicked on Node " + $Label.text) #Prints the name of the node that is clicked on
		#print(str(node_RPU.RPU) + " " + str(node_RPU.Population))
		_update_ui()

		A_node_clicked.emit(name,multiplayer.get_unique_id(),"Node")

func add_building(player_ID:int, _type:int, color:Vector3) -> void:
	building = base_resource.duplicate(true)
	node_owner = str(player_ID) #player_list[Overseer.selected_player_index].Player_name
	#var color:Vector3 = get_parent().Current_player.color #players_colors[Overseer.selected_player_index]
	building.location = int(name)
	building.color = color
	building.player_ID = player_ID
	#Overseer.player_list[Overseer.selected_player_index]
	#get_parent().Current_player.base_list.append(building) #adds building to the base list
	if multiplayer.is_server():
		Overseer.Identify_player(player_ID).base_list.append(building) #adds building to the base list

	%Building.material.set_shader_parameter("tint_color", color)
	%Building.material.set_shader_parameter("saturation", 0.4)
	%Building.show()
	Has_building = true
	attempt_place_dock()

func remove_building() -> void:
	if Has_building and building:
		var owning_player:Resource = Overseer.Identify_player(building.player_ID)
		if owning_player:
			for base_index:int in range(owning_player.base_list.size() - 1, -1, -1):
				var base:Resource = owning_player.base_list[base_index]
				if base.location == building.location:
					owning_player.base_list.remove_at(base_index)
					break
	building = null
	Has_building = false
	node_owner = ""
	%Building.hide()

func add_unit(player:int, type:int, color:Vector3, UUID:String, disrupted:bool, DID_HE_MOVED:bool = false, is_reconstituted:bool = false) -> void:
	var unique_unit:Resource
	if type == FIGHTER:
		unique_unit = fighter_resource.duplicate(true)
		unique_unit.player_ID = player
		unique_unit.color = color #get_parent().Current_player.color #players_colors[Overseer.selected_player_index]
	
	else:
		unique_unit = influence_resource.duplicate(true)
		unique_unit.player_ID = player
		unique_unit.color = color #get_parent().Current_player.color #players_colors[Overseer.selected_player_index]
		attempt_place_dock()
	
	unique_unit.has_moved = DID_HE_MOVED
	unique_unit.unit_UUID = UUID
	unique_unit.disrupted = disrupted
	unique_unit.been_reconstituted = is_reconstituted
	unit_list.append(unique_unit) # ADD UNIT DATA
	
	var unit_visual := unit_scene.instantiate() #GENERATE VISUAL
	unit_visual.Unit_Data = unique_unit
	if disrupted:
		unit_visual.set_disrupted()
	%Units.add_child(unit_visual)
	reorder_units()
	get_parent().find_child("UI").update_node_unit_list(unit_list,name)

func has_unit(player:int, type:int) -> bool:
	for unit:Resource in unit_list:
		if (unit.player_ID == player) and (unit.unit_type == type):
			return true
	return false

func remove_unit(player:int,type:int,search_by_UUID:bool = false,UUID:String = "") -> void: ## TODO: HANDLE RECONSTITUTABLE UNITS (THIS DOES NOT CARE ABOUT UNIT STATE, CURRENTLY ONLY TYPE AND PLAYER) 
	if search_by_UUID:                                                                              ## chat we fixed this ^
		for unit:Resource in unit_list: # DELETE UNIT DATA
			if (unit.player_ID == player) and (unit.unit_type == type) and (unit.unit_UUID == UUID):
				unit_list.erase(unit) 
				break
		for unit:Node in %Units.get_children(): # DELETE UNIT VISUAL
			if (unit.Unit_Data.player_ID == player) and (unit.Unit_Data.unit_type == type) and (unit.Unit_Data.unit_UUID == UUID):
				unit.queue_free()
				await unit.tree_exited
				reorder_units()
				break
	else:
		for unit:Resource in unit_list: # DELETE UNIT DATA
			if (unit.player_ID == player) and (unit.unit_type == type):
				unit_list.erase(unit) 
				break
		for unit:Node in %Units.get_children(): # DELETE UNIT VISUAL
			if (unit.Unit_Data.player_ID == player) and (unit.Unit_Data.unit_type == type):
				unit.queue_free()
				await unit.tree_exited
				reorder_units()
				break

func Find_first_of_unit(player:int, type:int) -> Resource:
	for unit:Resource in unit_list:
		if (unit.player_ID == player) and (unit.unit_type == type):
			return unit
	return Resource.new()

func reorder_units() -> void:
	var nodes:Array = %Units.get_children()
	var count:int = nodes.size()
	var min_x:float 
	var max_x:float
	min_x = max(-10-(count*5),-80)
	max_x = min(10+(count*5),80)
	
	if count == 0:
		return
	if count == 1:
		nodes[0].position.x = (min_x + max_x) / 2
		return
	
	var spacing:float = (max_x - min_x) / (count - 1)
	for i in range(count):
		nodes[i].position.x = min_x + i * spacing
		
		if (i % 2 != 0) && count > 2:
			nodes[i].Unit_Data.offcolor = true
			nodes[i].recolor()
	

func _randomize_sprites() -> void:
	var top_array:Array = [
	preload("res://Assets/Map_Tiles/Top/node_split_top.png"),
	preload("res://Assets/Map_Tiles/Top/node_split_top_2.png"),
	preload("res://Assets/Map_Tiles/Top/node_split_top_3.png"),
	preload("res://Assets/Map_Tiles/Top/node_split_top_4.png"),
	]
	var base_array:Array = [
	preload("res://Assets/Map_Tiles/Base/node_split_base.png"),
	preload("res://Assets/Map_Tiles/Base/node_split_base_2.png"),
	preload("res://Assets/Map_Tiles/Base/node_split_base_3.png"),
	preload("res://Assets/Map_Tiles/Base/node_split_base_4.png")
	]
	var random_index:int = randi() % top_array.size()
	var selected_sprite:Texture= top_array[random_index]
	$Node_top.texture = selected_sprite
	random_index = randi() % base_array.size()
	selected_sprite = base_array[random_index]
	$Node_Body.texture = selected_sprite
	
	var count:int = randi_range(1, 5)   
	var foliage:PackedScene = preload("res://MapStuff/MapNode/Foliage.tscn")
	#var center:Vector2 = position
	for i in range(count):
		var new_foliage:Node2D = foliage.instantiate()
		var offset:Vector2 = get_random_point_in_ellipse(0,0,68,30)
		new_foliage.position = Vector2(0,-10)+offset
		$Sort.add_child(new_foliage)
		
func get_random_point_in_ellipse(cx:int,cy:int,a:int,b:int) -> Vector2:
	#var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	var t:float = 2.0 * PI * randf()              # random angle
	var r:float = sqrt(randf())                   # area-correct radial distribution
	var x:float = cx + a * r * cos(t)
	var y:float = cy + b * r * sin(t)
	return Vector2(x, y)

func remove_selection_circle() -> void:
	target_radius = 0.1
	target_speed  = 3.0
	lerpspeed=0.05

func add_selection_circle() -> void:
	target_radius = 0.25
	target_speed  = 1.0
	lerpspeed=0.3

@rpc("any_peer","call_local")
func flare(player_ID:int) -> void:
	var player_resource:Player = Overseer.Identify_player(player_ID)
	var instanced_flare:= flare_scene.instantiate()
	instanced_flare.position.y-= 130
	instanced_flare.light_color = player_resource.color
	add_child(instanced_flare)
	

var lerpspeed:float = 0.5
var current_radius:  float = 0.0
var target_radius:   float = 0.0

var current_speed:   float = 0.0
var target_speed:    float = 0.0

func _process(_delta:float) -> void:
	current_radius = lerp(current_radius, target_radius, lerpspeed)
	current_speed  = lerp(current_speed,  target_speed,  lerpspeed)
	%Selection_Circle.material.set_shader_parameter("radius", current_radius)
	%Selection_Circle.material.set_shader_parameter("speed", current_speed)
	var color:Vector3 = Player_color #get_parent().Current_player.color 
	var color_2:Vector4 = Vector4(color.x,color.y,color.z,0.5)
	%Selection_Circle.material.set_shader_parameter("color", color_2)



func spawn_dock(duration: float = 0.5) -> void:
	%Dock.show()
	fade_material.set_shader_parameter("progress", 0.0)

	var tween := create_tween()
	tween.tween_method(
		func(v: float) -> void: fade_material.set_shader_parameter("progress", v),
		0.0,
		1.0,
		duration
	)

func despawn_dock(duration: float = 0.5) -> void:
	fade_material.set_shader_parameter("progress", 1.0)

	var tween := create_tween()
	tween.tween_method(
		func(v: float) -> void: fade_material.set_shader_parameter("progress", v),
		1.0,
		0.0,
		duration
	)

	await tween.finished
	%Dock.hide()

func attempt_place_dock() -> void:
	if %Dock.visible:
		return
	if Overseer.The_support_nodes.has(name):
		if position.x > 0:
			%Dock.texture = dock_right
			spawn_dock()
		else:
			%Dock.texture = dock_left
			spawn_dock()
