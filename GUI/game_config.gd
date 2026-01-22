extends CanvasLayer
var map_generator:PackedScene = preload("res://MapStuff/MapGeneration/map_generator.tscn")
var size:int = 2
@onready var client:Node = $Client
var UI_player:PackedScene = preload("res://GUI/Lobby_ui_player.tscn")

func _ready() -> void:
	client.lobby_joined.connect(_lobby_joined)
	multiplayer.peer_connected.connect(Add_player_resource)
	Overseer.player_resources_updated.connect(_render_players)
	multiplayer.peer_disconnected.connect(Remove_player_resource)
	show()
	$Error_Message.hide()
	%Color_select.disabled = true
	%Faction_select.disabled = true
	#_start_map_gen() #hardcoded disabling config menu

func _on_start_button_pressed() -> void:
	for Players:Resource in Overseer.player_list:
		if Players.Player_faction == 1:
			Players.Player_storage["Military_Base"] = 2
			Players.Player_storage["Influence"] = 2
			Players.Player_storage["Intelligence"] = 3
			Players.Player_storage["Logistics"] = 3
		else:
			Players.Player_storage["Military_Base"] = 1
			Players.Player_storage["Influence"] = 1
			Players.Player_storage["Intelligence"] = 2
			Players.Player_storage["Logistics"] = 2
	_start_map_gen()
	Overseer.Resources_to_rpc()
	#Overseer.cycle_players()

func _start_map_gen() -> void:
	var spawn_map_generator:Node = map_generator.instantiate()
	spawn_map_generator.size = size 
	get_parent().add_child.call_deferred(spawn_map_generator)
	hide()

func _on_option_button_item_selected(index: int) -> void:
	size = index
	pass # Replace with function body.

func _on_join_button_pressed() -> void:
	client.start(%IP.text, %Room.text, true)
	#Add_player_resource(1)

func _lobby_joined(lobby:String) -> void:
	%Room.text = lobby
	%Room.editable = false
	%Join_Button.disabled = true
	Add_player_resource(1)
	if multiplayer.is_server():
		%StartButton.set_disabled(false)
		%OptionButton.set_disabled(false)
	else:
		%StartButton.set_disabled(true)
		%OptionButton.set_disabled(true)


func Add_player_resource(ID:int) -> void:
	if multiplayer.is_server():
		var Player_resource:Resource = Player.new()
		Player_resource.Player_ID = ID
		Player_resource.Money = 300
		Player_resource.Man_power = 300
		Player_resource.Weapons = 300
		Overseer.player_list.append(Player_resource)
		var Logistics_map:AStar2D = AStar2D.new()
		var Intelligence_map:AStar2D = AStar2D.new()
		Overseer.The_networks[ID] = [Intelligence_map,Logistics_map]
		Overseer.Resources_to_rpc()
		#Overseer.Player_rpc_info["Player " +str(ID)] = [Overseer.Player_resource.Player_ID,Overseer.Player_resource.Player_name,Overseer.Player_resource.color,Overseer.Player_resource.base_list,Overseer.Player_resource.Weapons,Overseer.Player_resource.Money,Overseer.Player_resource.Man_power,Overseer.Player_resource.Victory_points]

func Remove_player_resource(ID:int) -> void: 
	if multiplayer.is_server():
		for existing_player:Resource in Overseer.player_list: 
			if existing_player.Player_ID == ID:
				Overseer.player_list.remove_at(Overseer.player_list.find(existing_player))
				Overseer.The_networks.erase(ID)
				Overseer.Resources_to_rpc()

func _render_players() -> void:
	%Color_select.disabled = false
	%Faction_select.disabled = false
	for existing_child:Node in %Player_list_container.get_children():
		%Player_list_container.remove_child(existing_child)
		existing_child.queue_free()
	for player:Resource in Overseer.player_list:
		var new_player_scene:Node = UI_player.instantiate()
		new_player_scene.update_text(str(player.Player_ID))
		if player.color:
			new_player_scene.update_color(player.color.normalized())
		%Player_list_container.add_child(new_player_scene)

func _on_color_select_item_selected(index: int) -> void:
	Update_player_color.rpc(multiplayer.get_unique_id(),index)

@rpc("any_peer","call_local")
func Update_player_color(ID:int,Color_ID:int) -> void:
	if multiplayer.is_server():
		var Selected_color:Vector3
		for player:Resource in Overseer.player_list:
			if player.Player_ID == ID: 
				match Color_ID:
					0:
						Selected_color = Vector3(223, 0, 81)/255
					1:
						Selected_color = Vector3(186, 165, 0)/255
					2:
						Selected_color = Vector3(235, 136, 41)/255
					3:
						Selected_color = Vector3(46, 197, 0)/255
					4:
						Selected_color = Vector3(88, 167, 255)/255
					5:
						Selected_color = Vector3(207, 118, 255)/255
				var picked:bool = false
				for Sub_player:Resource in Overseer.player_list:
					if Sub_player.color == Selected_color:
						picked = true
						color_pick_failed.rpc(ID)
				if picked == false:
					player.color = Selected_color
					Overseer.Resources_to_rpc()

@rpc("any_peer","call_local")
func color_pick_failed(ID:int) -> void:
	if multiplayer.get_unique_id() == ID:
		action_error("this color has been selected!")
		%Color_select.select(-1)

func action_error(error_message:String) -> void:
	$Error_Message.text = error_message
	$Error_Message.show()
	$Error_timer.start()


func _on_error_timer_timeout() -> void:
	$Error_Message.hide()


func _on_room_text_changed() -> void:
	if %Room.text == "":
		%Join_Button.text = "Create lobby"
		%StartButton.set_disabled(false)
		%OptionButton.set_disabled(false)
	else:
		%Join_Button.text = "Join lobby" 
		%StartButton.set_disabled(true)
		%OptionButton.set_disabled(true)


func _on_join_debug_pressed() -> void:
	client.start(%IP.text, "debug", true) # Replace with function body.

func _on_faction_select_item_selected(index: int) -> void:
	Update_player_faction.rpc(multiplayer.get_unique_id(),index)

@rpc("any_peer","call_local")
func Update_player_faction(ID:int,Faction_ID:int) -> void:
	if multiplayer.is_server():
		for player:Resource in Overseer.player_list:
			if player.Player_ID == ID: 
				player.Player_faction = Faction_ID
		Overseer.Resources_to_rpc()
