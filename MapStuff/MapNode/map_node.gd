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
enum{FIGHTER,INFLUENCE}

func _ready() -> void:
	$Map_Node_Area2D.set_pickable(true) #sets-up the clickable area for the map nodes
	#$Building.hide() 
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
		

func _update_label()-> void:
	$Label.text = name

# Detects when Node is clicked on by mouse
func _on_map_node_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("Mouse_left_click"): 
		#print("you have clicked on Node " + $Label.text) #Prints the name of the node that is clicked on
		#print(str(node_RPU.RPU) + " " + str(node_RPU.Population))
		A_node_clicked.emit(name)

func add_building(player:String, _type:int, color:Vector3) -> void:
	building = base_resource.duplicate(true)
	node_owner = get_parent().Current_player.Player_name #player_list[Overseer.selected_player_index].Player_name
	#var color:Vector3 = get_parent().Current_player.color #players_colors[Overseer.selected_player_index]
	building.location = int(name)
	#Overseer.player_list[Overseer.selected_player_index]
	get_parent().Current_player.base_list.append(building) #adds building to the base list

	%Building.material.set_shader_parameter("tint_color", color)
	%Building.material.set_shader_parameter("saturation", 0.4)
	%Building.show()

func add_unit(player:String, type:int, color:Vector3) -> void:
	var unique_unit:Resource
	if type == FIGHTER:
		unique_unit = fighter_resource.duplicate(true)
		unique_unit.player = player
		unique_unit.color = color #get_parent().Current_player.color #players_colors[Overseer.selected_player_index]
		
	else:
		unique_unit = influence_resource.duplicate(true)
		unique_unit.player = player
		unique_unit.color = get_parent().Current_player.color #players_colors[Overseer.selected_player_index]
		

	unit_list.append(unique_unit)
	
	var unit_visual := unit_scene.instantiate()
	unit_visual.Unit_Data = unique_unit
	%Units.add_child(unit_visual)
	#print("added child")
	_reorder_units()

func _reorder_units() -> void:
	
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
	#print("removing circle from %s" % name)
	pass

func add_selection_circle() -> void:
	target_radius = 0.25
	target_speed  = 1.0
	lerpspeed=0.3

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
	var color:Vector3 = get_parent().Current_player.color 
	var color_2:Vector4 = Vector4(color.x,color.y,color.z,0.5)
	%Selection_Circle.material.set_shader_parameter("color", color_2)
