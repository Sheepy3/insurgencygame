extends Node2D
signal A_path_clicked(Name: String)
@export var connection:Vector2
@export var Has_intel:Dictionary 
@export var Has_logs:Dictionary  
var intel_color_index:int = 0
var logs_color_index:int = 0
#@export var networks:Array #This variable can be depricated due to lack of use

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
	if multiplayer.is_server():
		for players:Resource in Overseer.player_list:
			Has_intel[players.Player_ID] = false
			Has_logs[players.Player_ID] = false

	if rad_to_deg(rotation) > 90:
		%Intelligence_Network.set_flip_v(true)
		%Intelligence_Network.set_flip_h(true)
		%Intelligence_Network/Intelligence_Text.set_flip_v(true)
		%Intelligence_Network/Intelligence_Text.set_flip_h(true)
		%Logistics_Network.set_flip_v(true)
		%Logistics_Network.set_flip_h(true)
		%Logistics_Network/Logistics_Text.set_flip_v(true)
		%Logistics_Network/Logistics_Text.set_flip_h(true)

func _on_node_path_area_2d_input_event(_viewport: Node,event: InputEvent,_shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and not event.pressed:
		print("you have clicked on Path " + name)
		find_parent("Map_parent").find_child("Dynamic_Clicked").text = "Path " + name
		A_path_clicked.emit(name,multiplayer.get_unique_id(),"Path")

func add_intel_network(Currnet_player_color:Vector3) -> void:
	if not %Intelligence_Network.visible:
		%Intelligence_Network.show()
		%Intelligence_Network.material.set_shader_parameter("tint_color",Currnet_player_color)
		%Intelligence_Text.material.set_shader_parameter("tint_color", Currnet_player_color)

func add_logistics_network(Currnet_player_color:Vector3) -> void:
	if not %Logistics_Network.visible:
		%Logistics_Network.show()
		%Logistics_Network/Logistics_Text.material.set_shader_parameter("tint_color", Currnet_player_color)
		%Logistics_Network.material.set_shader_parameter("tint_color", Currnet_player_color)


func _on_color_switch_timeout() -> void:
	
	var intel_player_ids: Array = Has_intel.keys().filter(
	func(player_id: Variant) -> bool:
		return Has_intel[player_id] == true
	)
	if not intel_player_ids.is_empty():
		intel_color_index = (intel_color_index + 1) % intel_player_ids.size()
		var intel_player:Player = Overseer.Identify_player(intel_player_ids[intel_color_index])
		if intel_player:
			%Intelligence_Network.material.set_shader_parameter("tint_color", intel_player.color)
			%Intelligence_Text.material.set_shader_parameter("tint_color", intel_player.color)

	var logs_player_ids: Array = Has_logs.keys().filter(
	func(player_id: Variant) -> bool:
		return Has_logs[player_id] == true
	)
	if not logs_player_ids.is_empty():
		logs_color_index = (logs_color_index + 1) % logs_player_ids.size()
		var logs_player:Player = Overseer.Identify_player(logs_player_ids[logs_color_index])
		if logs_player:
			%Logistics_Network/Logistics_Text.material.set_shader_parameter("tint_color", logs_player.color)
			%Logistics_Network.material.set_shader_parameter("tint_color", logs_player.color)
