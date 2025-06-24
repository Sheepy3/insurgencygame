extends Node2D
signal A_path_clicked(Name: String)
@export var connection:Vector2
@export var Has_intel: bool = false
@export var Has_logs: bool = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Node_Path_Area2D.set_pickable(true) #sets-up the clickable area for the path nodes
	$Intelligence_Network.hide()
	$Logistics_Network.hide()
	look_at(connection) # point towards connection

	if rad_to_deg(rotation) > 90:
		$Intelligence_Network.set_flip_v(true)
		$Intelligence_Network.set_flip_h(true)
		$Logistics_Network.set_flip_v(true)
		$Logistics_Network.set_flip_h(true)

func _on_node_path_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("Mouse_left_click"): 
		print("you have clicked on Path " + name)
		find_parent("Map_parent").find_child("Dynamic_Clicked").text = "Path " + name
		A_path_clicked.emit(name)
