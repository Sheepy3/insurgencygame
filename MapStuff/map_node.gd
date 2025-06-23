extends Node2D
signal A_node_clicked(Name: String)
#var On_node: String = ""
var Has_building: bool = false
var building:Resource
@export var node_owner:String

func _ready() -> void:
	$Map_Node_Area2D.set_pickable(true) #sets-up the clickable area for the map nodes
	$Building.hide() 

	if get_parent().name != "root":
		get_parent().update_label.connect(_update_label)

func _update_label()-> void:
	$Label.text = name

# Detects when Node is clicked on by mouse
func _on_map_node_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("Mouse_left_click"): 
		#print("you have clicked on Node " + $Label.text) #Prints the name of the node that is clicked on
		get_parent().find_child("Dynamic_Clicked").text = "Node " + $Label.text #Dispalys 
		A_node_clicked.emit(name)

var unit_list:Array 
var fighter_resource:Resource=load("res://Resources/Fighter.tres")
var influence_resource:Resource=load("res://Resources/Influence.tres")
var base_resource:Resource=load("res://Resources/Miliary_Base.tres")

var unit_scene:PackedScene = load("res://MapStuff/Unit_Visual.tscn")
enum{FIGHTER,INFLUENCE}

func add_building(player:String, _type:int) -> void:
	building = base_resource.duplicate(true)
	node_owner = player
	var color:Vector3 = Overseer.players_colors[Overseer.selected_player_index]
	#print(color)
	$Building.material.set_shader_parameter("tint_color", color)
	$Building.material.set_shader_parameter("intensity", 0.1)
	$Building.material.set_shader_parameter("saturation", 2)
	$Building.show()
	
func add_unit(player:String, type:int) -> void:
	var unique_unit:Resource
	if type == FIGHTER:
		unique_unit = fighter_resource.duplicate(true)
		unique_unit.player = player
		unique_unit.color = Overseer.players_colors[Overseer.selected_player_index]
		
	else:
		unique_unit = influence_resource.duplicate(true)
		unique_unit.player = player
		unique_unit.color = Overseer.players_colors[Overseer.selected_player_index]
		

	unit_list.append(unique_unit)
	
	var unit_visual := unit_scene.instantiate()
	unit_visual.Unit_Data = unique_unit
	$Units.add_child(unit_visual)
	#print("added child")
	_reorder_units()

func _reorder_units() -> void:
	
	var nodes:Array = $Units.get_children()
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
