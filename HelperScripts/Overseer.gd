extends Node

#todo: convert player system to use resources for each player. these variables are gonna be unstable
#when networking is added, and the "current player" thing doesnt work if players take turns at the same time. 

#var players:Array = ["Player 1", "Player 2"] #currently hardcoded, would be procedurally generated based on playercount
#var players_colors:Array = [Vector3(1.0,0.0,0.0),Vector3(0.0,1.0,0.0)]
var player_list:Array
var Player_resource:Resource = load("res://Resources/Preset/Player_Default.tres")
var unit_scene:PackedScene = load("res://MapStuff/Unit_Visual.tscn")
#var selected_player_index:int = -1
var current_player:String
#var Logistics_array:Array 
#var Intelligence_array:Array
var The_networks:Dictionary
var The_nodes:Dictionary
var The_support_nodes:Array
var Phase_cycle:int = 0
var Desired_cycle:int = 3
 
enum {MAINTENENCE, PURCHASE, PLACE, UNIT_MOVEMENT, COLLECT}
var current_phase:int = MAINTENENCE

signal change_player
signal game_started
signal change_phase
signal player_resources_updated
signal Initialization_player_color

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
	Create_unique_ID()
	pass
	#populate_player_list(2)
	#Pull_player_info()

@rpc("any_peer","call_local")
func Resources_to_rpc() -> void:
	if multiplayer.is_server():
		#var Player_rpc_info:Dictionary
		#for Players:Resource in player_list:
			#Player_rpc_info[str(Players.Player_ID)] = [Players.Player_ID,Players.Player_name,Players.Player_faction,Players.color,Players.base_list,Players.Weapons,Players.Money,Players.Man_power,Players.Victory_points,Players.Player_storage, Players.Ready]
		#Rpc_to_resources.rpc(Player_rpc_info)
		Player_resources_to_rpc.rpc()
		player_resources_updated.emit()
		Initialization_player_color.emit()

#@rpc("authority","call_remote")
#func Rpc_to_resources(Player_rpc_info:Dictionary) -> void:
	#player_list = []
	#The_networks = {}
	#for Keys:String in Player_rpc_info.keys():
		#var New_player_resource:Resource = Player.new()
		#var Values:Array = Player_rpc_info[Keys]
		#New_player_resource.Player_ID = Values[0]
		#New_player_resource.Player_name = Values[1]
		#New_player_resource.Player_faction = Values[2]
		#New_player_resource.color = Values[3]
		#New_player_resource.base_list = Values[4]
		#New_player_resource.Weapons = Values[5]
		#New_player_resource.Money = Values[6]
		#New_player_resource.Man_power = Values[7]
		#New_player_resource.Victory_points = Values[8]
		#New_player_resource.Player_storage = Values[9]
		#New_player_resource.Ready = Values[10]
		#player_list.append(New_player_resource)
	#player_resources_updated.emit()
	#Initialization_player_color.emit()

@rpc("any_peer","call_local")
func Player_resources_to_rpc() -> void:
	if multiplayer.is_server():
		var Player_rpc_info:Array
		for Players:Resource in player_list:
			Player_rpc_info.append(Pack_Resource_data(Players))  
		Rpc_to_player_resources.rpc(Player_rpc_info)
		player_resources_updated.emit()

@rpc("authority","call_remote")
func Rpc_to_player_resources(new_player_info:Array) -> void:
	player_list.clear()
	for indexes:Dictionary in new_player_info:
		var new_player_resource:Resource = Instantiate_by_class_name(indexes["Resource_type"])
		for keys:String in indexes.keys():
			if keys != "Resource_type":
				if keys == "base_list" && indexes[keys].size() > 0:
					var new_base_list:Array
					for base_info:Dictionary in indexes[keys].values():     
						var new_base:Resource = Instantiate_by_class_name(base_info["Resource_type"])
						for base_keys:String in base_info.keys():
							if base_keys != "Resource_type":
								new_base.set(base_keys,base_info[base_keys])
						new_base_list.append(new_base)
					new_player_resource.set(keys,new_base_list)
				else:
					new_player_resource.set(keys,indexes[keys]) 
		player_list.append(new_player_resource)
	player_resources_updated.emit()
	Initialization_player_color.emit()

@rpc("any_peer","call_local")
func Request_node_data(Edited_node_name:String) -> void:
	if multiplayer.is_server():
		#var New_node:Dictionary
		#var Edited_node:Node = get_parent().get_child(1).find_child(Edited_node_name)
		#if Edited_node.Has_building == true:
			#var building:Resource = Edited_node.building
			#New_node["Building"] = [building.unit_type,building.player_ID,building.color,building.location]
		#var x:int = 0
		#for units:Resource in Edited_node.unit_list:
			#var Unit_number:String = "Unit:" + str(x)
			#var New_unit:Resource = units
			#New_node[Unit_number] = [New_unit.unit_type,New_unit.disrupted,New_unit.player_ID,New_unit.color,New_unit.offcolor]
			#x += 1
		#Update_node_data.rpc(Edited_node.name,New_node)
		New_request_node_data.rpc(Edited_node_name)

#@rpc("authority","call_remote")
#func Update_node_data(Edited_node_name:String,New_node_data:Dictionary) -> void:
	#var Edited_node:Node = get_parent().get_child(1).find_child(Edited_node_name)
	#var Present_unit_list:Array = Edited_node.find_child("Sort").find_child("Units").get_children() #get_parent().get_child(1).find_child(Edited_node_name).find_child("Sort").find_child("Units").get_children()
	#Edited_node.unit_list.clear()
	#for existing_units:Node in Present_unit_list:
		#existing_units.free()
	#var x:int = 0
	#for Placables:String in New_node_data.keys():
		#var Values:Array = New_node_data[Placables]
		#if Placables == "Building":
			#Edited_node.add_building(Values[1],Values[0],Values[2])
			#var Updates_to_building:Resource = Edited_node.building
			#Updates_to_building.unit_type = Values[0]
			#Updates_to_building.player_ID = Values[1]
			#Updates_to_building.color = Values[2]
			#Updates_to_building.location = Values[3]
		#elif Placables == "Unit:" + str(x):
			#Edited_node.add_unit(Values[3],Values[0],Values[4],Values[1])
			#x += 1

@rpc("any_peer","call_local")
func New_request_node_data(Edited_node_name:String) -> void:
	if multiplayer.is_server():
		var new_node:Array
		var Edited_node:Node = get_parent().get_child(1).find_child(Edited_node_name)
		if Edited_node.Has_building == true:
			new_node.append(Pack_Resource_data(Edited_node.building))
		for units:Resource in Edited_node.unit_list:
			new_node.append(Pack_Resource_data(units))
		Give_clients_node_data.rpc(Edited_node_name,new_node)

@rpc("authority","call_remote")
func Give_clients_node_data(Edited_node_name:String,Node_info:Array) -> void:
	var Edited_node:Node = get_parent().get_child(1).find_child(Edited_node_name)
	var Present_unit_list:Array = Edited_node.find_child("Sort").find_child("Units").get_children()
	Edited_node.unit_list.clear()
	for existing_units:Node in Present_unit_list:
		existing_units.free()
	for indexs:Dictionary in Node_info:
		var new_resource:Resource = Instantiate_by_class_name(indexs["Resource_type"])
		for keys:String in indexs.keys():
			if keys != "Resource_type":
				new_resource.set(keys,indexs[keys]) 
		if indexs["Resource_type"] == "Building":
				Edited_node.building = new_resource
				Edited_node.find_child("Building").material.set_shader_parameter("tint_color", indexs["color"])
				Edited_node.find_child("Building").material.set_shader_parameter("saturation",0.4)
				Edited_node.find_child("Building").show()
		else:
			Edited_node.unit_list.append(new_resource)
			var unit_visual:Node = unit_scene.instantiate()
			unit_visual.Unit_Data = new_resource
			Edited_node.find_child("Units").add_child(unit_visual)

@rpc("any_peer","call_local")
func Request_path_data(Requester_ID:int,Edited_path_name:String) -> void:
	if multiplayer.is_server():
		#var The_Roads: Array = Edited_path_name.split("-")
		#var Edited_path:Node = get_parent().get_child(1).find_child(The_Roads[0]).find_child(Edited_path_name)
		#var Path_data:Dictionary 
		#Path_data[Edited_path.name] = [Edited_path.connection,Edited_path.Has_intel,Edited_path.Has_logs,Identify_player(Requester_ID).color]
		#Update_path_data.rpc(Path_data,The_Roads[0])
		#Update_path_data(Path_data,The_Roads[0])
		#New_request_path_data(Requester_ID,Edited_path_name)
		New_request_path_data.rpc(Requester_ID,Edited_path_name)

#@rpc("authority","call_remote")
#func Update_path_data(New_path_data:Dictionary,The_Road:String) -> void:
	#The_networks = {}
	#var path_keys:Array = New_path_data.keys()
	#var Edited_path:Node = get_parent().get_child(1).find_child(The_Road).find_child(path_keys[0])
	#for keys:String in New_path_data.keys():
		#var Values:Array = New_path_data[keys]
		#Edited_path.connection = Values[0]
		#Edited_path.Has_intel = Values[1]
		#Edited_path.Has_logs = Values[2]
		#if Values[1] == true:
			#Edited_path.add_intel_network(Values[3])
		#if Values[2] == true:
			#Edited_path.add_logistics_network(Values[3])

@rpc("any_peer","call_local")
func New_request_path_data(Requester_ID:int,Edited_path_name:String) -> void:
	if multiplayer.is_server():
		var The_Roads:Array = Edited_path_name.split("-")
		var Edited_path:Node = get_parent().get_child(1).find_child(The_Roads[0]).find_child(Edited_path_name)
		var Path_data:Dictionary = {"Path_name":Edited_path.name}
		for indexes:Dictionary in Edited_path.get_property_list(): 
			if indexes["usage"] == 4102:
				Path_data[indexes["name"]] = Edited_path.get(indexes["name"])
		if Edited_path.Has_intel: 
			Path_data["intel"] = Edited_path.find_child("Intelligence_Network").material.get_shader_parameter("tint_color")
		if Edited_path.Has_logs: 
			Path_data["logs"] = Edited_path.find_child("Logistics_Network").material.get_shader_parameter("tint_color")
		Give_clients_path_data.rpc(Path_data,The_Roads[0],Identify_player(Requester_ID).color)

@rpc("authority","call_remote")
func Give_clients_path_data(New_path_data:Dictionary,The_Road:String,Network_color:Vector3) -> void:
	The_networks.clear()
	var Edited_path:Node = get_parent().get_child(1).find_child(The_Road).find_child(New_path_data["Path_name"])
	New_path_data.erase("Path_name")
	for Path_info:String in New_path_data.keys():
		Edited_path.set(Path_info,New_path_data[Path_info])
	for players:int in Edited_path.Has_intel.keys():
		if  Edited_path.Has_intel[players]: 
			Edited_path.add_intel_network(New_path_data["intel"])
			break
	for players:int in Edited_path.Has_logs.keys():
		if  Edited_path.Has_logs[players]:
			Edited_path.add_logistics_network(New_path_data["logs"])
			break

func Identify_player(Specific_ID:int) -> Resource:
	var Server_known_player:int = Specific_ID
	var Current_player:Resource
	for Player_Resources:Resource in player_list:
		if Player_Resources.Player_ID == Server_known_player:
			Current_player = Player_Resources
	return Current_player

func Create_unique_ID() -> String: 
	var hex_values:Array = [0,1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f"]
	var random_hex_string:String
	for i:int in range(0,36):
		if i == 8 or i == 13 or i == 18 or i == 23:
			random_hex_string += "-"
		elif i == 14:
			random_hex_string +=str(hex_values[4])
		elif i == 19:
			random_hex_string +=str(hex_values[randi_range(8,11)])
		else:
			random_hex_string +=str(hex_values[randi_range(0,15)])
	return random_hex_string

func Instantiate_by_class_name(class_name_string: StringName) -> Object:
	var class_list:Array = ProjectSettings.get_global_class_list()  
	for script_info:Dictionary in class_list:
		if script_info["class"] == class_name_string:
			var loaded_script:Resource = load(script_info["path"])
			if loaded_script:
				return loaded_script.new()
	var Error_node:Node = Node2D.new()
	Error_node.name == "The Script was not loaded properly"
	return Error_node

func Pack_Resource_data(Gift:Resource) -> Dictionary: #,args:Array) -> Dictionary: 
	var Wrapped_gift:Dictionary
	for indexes:Dictionary in Gift.get_property_list():
		if indexes["usage"] == 4102:
			Wrapped_gift["Resource_type"] = Gift.get_script().get_global_name().split("&")[0]
			if typeof(Gift.get(indexes["name"])) == TYPE_ARRAY:
				var recursive_dictionary:Dictionary
				for entries:Resource in Gift.get(indexes["name"]):
					recursive_dictionary[Create_unique_ID()] = Pack_Resource_data(entries)
				Wrapped_gift[indexes["name"]] = recursive_dictionary
			else:
				Wrapped_gift[indexes["name"]] = Gift.get(indexes["name"])
	return Wrapped_gift
