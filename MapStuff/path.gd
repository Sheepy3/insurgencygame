extends Node2D
signal A_path_clicked(Name: String)
@export var connection:Vector2
@export var Has_intel: bool = false
@export var Has_logs: bool = false 
@export var networks:Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Node_Path_Area2D.set_pickable(true) #sets-up the clickable area for the path nodes
	$BackBufferCopy/Intelligence_Network.hide()
	$BackBufferCopy/Logistics_Network.hide()
	#$Intelligence_Network/Intelligence_Text.play()
	#$Logistics_Network/Logistics_Text.play()
	look_at(connection) # point towards connection
	$BackBufferCopy/Mask.rotation=rotation*-1
	$BackBufferCopy/Mask2.rotation=rotation*-1
	$BackBufferCopy/Mask.global_position  -=Vector2(0,15)
	$BackBufferCopy/Mask2.global_position -=Vector2(0,15)

	if rad_to_deg(rotation) > 90:
		%Intelligence_Network.set_flip_v(true)
		%Intelligence_Network.set_flip_h(true)
		%Intelligence_Network/Intelligence_Text.set_flip_v(true)
		%Intelligence_Network/Intelligence_Text.set_flip_h(true)
		%Logistics_Network.set_flip_v(true)
		%Logistics_Network.set_flip_h(true)
		%Logistics_Network/Logistics_Text.set_flip_v(true)
		%Logistics_Network/Logistics_Text.set_flip_h(true)

func _on_node_path_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("Mouse_left_click"): 
		print("you have clicked on Path " + name)
		find_parent("Map_parent").find_child("Dynamic_Clicked").text = "Path " + name
		A_path_clicked.emit(name)

func add_intel_network() -> void:
	$Intelligence_Network.show()
	$Intelligence_Network.material.set_shader_parameter("tint_color", Overseer.players_colors[Overseer.selected_player_index])
	$Intelligence_Network/Intelligence_Text.material.set_shader_parameter("tint_color", Overseer.players_colors[Overseer.selected_player_index])
	pass

func add_logistics_network() -> void:
	$Logistics_Network.show()
	$Logistics_Network/Logistics_Text.material.set_shader_parameter("tint_color", Overseer.players_colors[Overseer.selected_player_index])
	$Logistics_Network.material.set_shader_parameter("tint_color", Overseer.players_colors[Overseer.selected_player_index])
	pass
