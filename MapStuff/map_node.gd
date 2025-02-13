extends Node2D
signal A_node_clicked(Name: String)
var On_node: String = ""
var Has_building: bool = false
var units:Array



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Map_Node_Area2D.set_pickable(true) #sets-up the clickable area for the map nodes
	$Building.hide() 
	$Fighter_Unit.hide() 
	$Influence_Unit.hide()
	if get_parent().name != "root":
		get_parent().update_label.connect(_update_label)
	
	pass # Replace with function body.
	
func _update_label()-> void:
	$Label.text = name
	pass

# Detects when Node is clicked on by mouse
func _on_map_node_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("Mouse_left_click"): 
		print("you have clicked on Node " + $Label.text) #Prints the name of the node that is clicked on
		get_parent().find_child("Dynamic_Clicked").text = "Node " + $Label.text #Dispalys 
		A_node_clicked.emit(name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_fighter_unit_visibility_changed() -> void:
	var color:Vector3 = Overseer.players_colors[Overseer.selected_player_index]
	$Fighter_Unit.material.set_shader_parameter("tint_color", color)
	$Fighter_Unit.material.set_shader_parameter("intensity", 0.2)
	$Fighter_Unit.material.set_shader_parameter("saturation", 2)
	pass # Replace with function body.


func _on_building_visibility_changed() -> void:
	var color:Vector3 = Overseer.players_colors[Overseer.selected_player_index]
	print(color)
	$Building.material.set_shader_parameter("tint_color", color)
	$Building.material.set_shader_parameter("intensity", 0.2)
	$Building.material.set_shader_parameter("saturation", 2)
