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
func Rpc_to_resources(Player_rpc_info:Dictionary) -> void: #,Player_rpc_maps:Dictionary
	player_list = []
	The_networks = {}
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
			var New_unit:Resource = units
			New_unit.color = Requester.color
			New_node[Unit_number] = [New_unit.unit_type,New_unit.unit_state,New_unit.player,New_unit.color,New_unit.offcolor]
			x += 1
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
			#var nodes_unit_list:Array = Edited_node.unit_list
			#nodes_unit_list[x].color = Values[3]
			x += 1

@rpc("any_peer","call_local")
func Request_path_data(Requester:Resource,Edited_path_name:String) -> void:
	var The_Roads: Array = Edited_path_name.split("-")
	var Edited_path:Node = get_parent().get_child(1).find_child(The_Roads[0]).find_child(Edited_path_name)
	var Path_data:Dictionary 
	#var Player_rpc_maps:Dictionary
	if multiplayer.is_server():
		#for players:int in The_networks.keys():
			#var Values:Array = The_networks[players]
			#Player_rpc_maps[players] = [Values[0],Values[1]]
		#if Edited_path.Has_logs == true or Edited_path.Has_logs == true:
		Path_data[Edited_path.name] = [Edited_path.connection,Edited_path.Has_intel,Edited_path.Has_logs,Requester.color]
		Update_path_data.rpc(Path_data,The_Roads[0])

@rpc("authority","call_remote")
func Update_path_data(New_path_data:Dictionary,The_Road:String) -> void:
	The_networks = {}
	var path_keys:Array = New_path_data.keys()
	#for players:int in New_Network_data.keys():
		#var Values:Array = New_Network_data[players]
		#The_networks[players] = [Values[0],Values[1]]
	var Edited_path:Node = get_parent().get_child(1).find_child(The_Road).find_child(path_keys[0])
	for keys:String in New_path_data.keys():
		var Values:Array = New_path_data[keys]
		Edited_path.connection = Values[0]
		Edited_path.Has_intel = Values[1]
		Edited_path.Has_logs = Values[2]
		if Values[1] == true:
			Edited_path.add_intel_network(Values[3])
		if Values[2] == true:
			Edited_path.add_logistics_network(Values[3])

#@rpc("any_peer","call_local")
#func Request_network_data() -> void: 
	

#@rpc("authority","call_remote")
#func Update_network_data() -> void:
	

func Identify_player() -> Resource:
	var Server_known_player:int = multiplayer.get_unique_id()
	var Current_player:Resource
	for Player_Resources:Resource in player_list:
		if Player_Resources.Player_ID == Server_known_player:
			Current_player = Player_Resources
	return Current_player

func Identify_player_paths(Pulled_map:int) -> AStar2D:
	var Server_known_player:int = multiplayer.get_unique_id()
	var Player_logs_map:AStar2D
	var Player_intel_map:AStar2D
	for IDs:int in The_networks.keys():
		if Server_known_player == IDs:
			var Values:Array = The_networks[IDs]
			if Pulled_map == 0:
				Player_intel_map = Values[0]
				return Player_intel_map
			elif Pulled_map == 1:
				Player_logs_map = Values[1]
				return Player_logs_map
	return 
