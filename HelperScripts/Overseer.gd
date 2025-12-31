extends Node

#todo: convert player system to use resources for each player. these variables are gonna be unstable
#when networking is added, and the "current player" thing doesnt work if players take turns at the same time. 

#var players:Array = ["Player 1", "Player 2"] #currently hardcoded, would be procedurally generated based on playercount
var players_colors:Array = [Vector3(1.0,0.0,0.0),Vector3(0.0,1.0,0.0)]
var player_list:Array
var Player_resource:Resource = load("res://Resources/Preset/Player_Default.tres")
#var selected_player_index:int = -1
var current_player:String
#var Logistics_array:Array 
#var Intelligence_array:Array
var The_networks:Dictionary
var The_nodes:Dictionary
var Phase_cycle:int = 0
var Desired_cycle:int = 3

enum {MAINTENENCE, PURCHASE, PLACE, UNIT_MOVEMENT, COLLECT}
var current_phase:int = MAINTENENCE

signal change_player
signal change_phase
signal player_resources_updated

#func populate_player_list(Game_Size:int)-> void:
	#for x:int in range(Game_Size):
		#player_list.append(Player_resource.duplicate(true))
		#Player_resource.color = players_colors[x]
		#player_list[x].Player_name = "Player " + str(x+1)
		#var Logistics_map:AStar2D = AStar2D.new()
		#var Intelligence_map:AStar2D = AStar2D.new()
		#Logistics_array.append(Logistics_map)
		#Intelligence_array.append(Intelligence_map)

#func cycle_players() -> void:
	#var playerquant:int = player_list.size()-1
	#if selected_player_index < playerquant:
		#selected_player_index +=1
		#current_player = player_list[selected_player_index].Player_name
		#change_player.emit()
	#else:
		#selected_player_index = 0
		#current_player = player_list[selected_player_index].Player_name
		#change_player.emit()

func cycle_phases() -> void:
	if Phase_cycle % Desired_cycle == 0 and current_phase == COLLECT:
		current_phase = 0
		change_phase.emit()
	elif current_phase == COLLECT and Phase_cycle % Desired_cycle != 0:
		current_phase = 1
		change_phase.emit()
	elif current_phase < COLLECT:
		current_phase+=1
		change_phase.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#populate_player_list(2)
	#Pull_player_info()

@rpc("any_peer","call_local")
func Resources_to_rpc() -> void:
	var Player_rpc_info:Dictionary
	if multiplayer.is_server():
		for Players:Resource in player_list:
			Player_rpc_info[str(Players.Player_ID)] = [Players.Player_ID,Players.Player_name,Players.color,Players.base_list,Players.Weapons,Players.Money,Players.Man_power,Players.Victory_points]
		Rpc_to_resources.rpc(Player_rpc_info)
		player_resources_updated.emit()

@rpc("authority","call_remote")
func Rpc_to_resources(Player_rpc_info:Dictionary) -> void:
	player_list = []
	for Keys:String in Player_rpc_info.keys():
		var Player_resource:Resource = Player.new()
		var Values:Array = Player_rpc_info[Keys]
		Player_resource.Player_ID = Values[0]
		Player_resource.Player_name = Values[1]
		Player_resource.color = Values[2]
		Player_resource.base_list = Values[3]
		Player_resource.Weapons = Values[4]
		Player_resource.Money = Values[5]
		Player_resource.Man_power = Values[6]
		Player_resource.Man_power = Values[7]
		player_list.append(Player_resource)
		player_resources_updated.emit()

@rpc("any_peer","call_local")
func Request_node_data(Requester:Resource,Edited_node_name:String) -> void:
	var New_node:Dictionary
	if multiplayer.is_server():
		var Edited_node:Node = get_parent().get_child(1).find_child(Edited_node_name)
		if Edited_node.Has_building == true:
			var building:Resource = Edited_node.building
			building.color = Requester.color
			building.player = Requester.Player_name
			New_node["Building"] = [building.unit_type,building.player,building.color,building.location]
		var x:int
		for units:Resource in Edited_node.unit_list:
			var Unit_number:String = "Unit:" + str(x)
			New_node[Unit_number] = [units.unit_type,units.unit_state,units.player,units.color,units.offcolor]
			x += 1
		print(New_node)
		Update_node_data.rpc(Edited_node.name,New_node)

@rpc("authority","call_remote")
func Update_node_data(Edited_node_name:String,New_node_data:Dictionary) -> void:
	var Edited_node:Node = get_parent().get_child(1).find_child(Edited_node_name)
	Edited_node.unit_list.clear()
	for Placables:String in New_node_data.keys():
		var Values:Array = New_node_data[Placables]
		var x:int
		if Placables == "Building":
			Edited_node.add_building(Values[1],Values[0],Values[2])
			var Updates_to_building:Resource = Edited_node.building
			Updates_to_building.unit_type = Values[0]
			Updates_to_building.player = Values[1]
			Updates_to_building.color = Values[2]
			Updates_to_building.location = Values[3]
		if Placables == "Unit:" + str(x):
			Edited_node.add_unit(Values[2],Values[0],Values[3])
			x += 1

func Identify_player() -> Resource:
	var Server_known_player:int = multiplayer.get_unique_id()
	var Current_player:Resource
	for Player_Resources:Resource in player_list:
		if Player_Resources.Player_ID == Server_known_player:
			Current_player = Player_Resources
	return Current_player
