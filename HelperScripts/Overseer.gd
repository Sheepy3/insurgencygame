extends Node

#todo: convert player system to use resources for each player. these variables are gonna be unstable
#when networking is added, and the "current player" thing doesnt work if players take turns at the same time. 

#var players:Array = ["Player 1", "Player 2"] #currently hardcoded, would be procedurally generated based on playercount
#var players_colors:Array = [Vector3(1.0,0.0,0.0),Vector3(0.0,1.0,0.0)]
var player_list:Array
var Player_resource:Resource = load("res://Resources/Preset/Player_Default.tres")
#var selected_player_index:int = -1
var current_player:String
#var Logistics_array:Array 
#var Intelligence_array:Array
var The_networks:Dictionary
var The_nodes:Dictionary
var The_support_nodes:Array
var Phase_cycle:int = 0
var Desired_cycle:int = 3
var lock:bool = false
enum {MAINTENENCE, PURCHASE, PLACE, UNIT_MOVEMENT, COLLECT}
var current_phase:int = MAINTENENCE

signal change_player
signal game_started
signal change_phase
signal player_resources_updated
signal Initialization_player_color

const PLAYER_COLORS := {
	"Red": Vector3(223, 0, 81) / 255.0,
	"Yellow": Vector3(186, 165, 0) / 255.0,
	"Orange": Vector3(235, 136, 41) / 255.0,
	"Green": Vector3(46, 197, 0) / 255.0,
	"Blue": Vector3(88, 167, 255) / 255.0,
	"Purple": Vector3(207, 118, 255) / 255.0,
}

const PLAYER_COLOR_ORDER := [
	"Red",
	"Yellow",
	"Orange",
	"Green",
	"Blue",
	"Purple",
]

func get_player_color_by_index(index: int) -> Vector3:
	if index < 0 or index >= PLAYER_COLOR_ORDER.size():
		return Vector3(1, 1, 1)
	var color_name: String = PLAYER_COLOR_ORDER[index]
	return PLAYER_COLORS[color_name]

func get_player_color_name(color: Vector3) -> String:
	for color_name: String in PLAYER_COLORS.keys():
		var stored_color: Vector3 = PLAYER_COLORS[color_name]
		if stored_color.distance_to(color) < 0.001:
			return color_name

	return "Unknown"
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

func _ready() -> void:
	pass

@rpc("any_peer","call_local")
func Resources_to_rpc() -> void:
	var Player_rpc_info:Dictionary
	if multiplayer.is_server():
		for Players:Resource in player_list:
			Player_rpc_info[str(Players.Player_ID)] = [Players.Player_ID,Players.Player_name,Players.Player_faction,Players.color,Players.base_list,Players.Weapons,Players.Money,Players.Man_power,Players.Victory_points,Players.Player_storage, Players.Ready]
		Rpc_to_resources.rpc(Player_rpc_info)
		player_resources_updated.emit()
		Initialization_player_color.emit()

@rpc("authority","call_remote")
func Rpc_to_resources(Player_rpc_info:Dictionary) -> void:
	player_list = []
	The_networks = {}
	for Keys:String in Player_rpc_info.keys():
		var New_player_resource:Resource = Player.new()
		var Values:Array = Player_rpc_info[Keys]
		New_player_resource.Player_ID = Values[0]
		New_player_resource.Player_name = Values[1]
		New_player_resource.Player_faction = Values[2]
		New_player_resource.color = Values[3]
		New_player_resource.base_list = Values[4]
		New_player_resource.Weapons = Values[5]
		New_player_resource.Money = Values[6]
		New_player_resource.Man_power = Values[7]
		New_player_resource.Victory_points = Values[8]
		New_player_resource.Player_storage = Values[9]
		New_player_resource.Ready = Values[10]
		player_list.append(New_player_resource)
	player_resources_updated.emit()
	Initialization_player_color.emit()

@rpc("any_peer","call_local")
func Request_node_data(Edited_node_name:String) -> void:
	var New_node:Dictionary
	if multiplayer.is_server():
		var Edited_node:Node = get_parent().get_child(1).find_child(Edited_node_name)
		if Edited_node.Has_building == true:
			var building:Resource = Edited_node.building
			New_node["Building"] = [building.unit_type,building.player_ID,building.color,building.location]
		var x:int = 0
		for units:Resource in Edited_node.unit_list:
			var Unit_number:String = "Unit:" + str(x)
			var New_unit:Resource = units
			New_node[Unit_number] = [New_unit.unit_type,New_unit.unit_UUID,New_unit.disrupted,New_unit.player_ID,New_unit.color,New_unit.offcolor]
			x += 1
		Update_node_data.rpc(Edited_node.name,New_node)

@rpc("authority","call_remote")
func Update_node_data(Edited_node_name:String,New_node_data:Dictionary) -> void:
	var Edited_node:Node = get_parent().get_child(1).find_child(Edited_node_name)
	var Present_unit_list:Array = get_parent().get_child(1).find_child(Edited_node_name).find_child("Sort").find_child("Units").get_children()
	Edited_node.unit_list.clear()
	for existing_units:Node in Present_unit_list:
		existing_units.free()
	var x:int = 0
	for Placables:String in New_node_data.keys():
		var Values:Array = New_node_data[Placables]
		if Placables == "Building":
			Edited_node.add_building(Values[1],Values[0],Values[2])
			var Updates_to_building:Resource = Edited_node.building
			Updates_to_building.unit_type = Values[0]
			Updates_to_building.player_ID = Values[1]
			Updates_to_building.color = Values[2]
			Updates_to_building.location = Values[3]
		elif Placables == "Unit:" + str(x):
			Edited_node.add_unit(Values[3],Values[0],Values[4],Values[1])
			x += 1

@rpc("any_peer","call_local")
func Request_path_data(Requester:Resource,Edited_path_name:String) -> void:
	var The_Roads: Array = Edited_path_name.split("-")
	var Edited_path:Node = get_parent().get_child(1).find_child(The_Roads[0]).find_child(Edited_path_name)
	var Path_data:Dictionary 
	if multiplayer.is_server():
		Path_data[Edited_path.name] = [Edited_path.connection,Edited_path.Has_intel,Edited_path.Has_logs,Requester.color]
		Update_path_data.rpc(Path_data,The_Roads[0])

@rpc("authority","call_remote")
func Update_path_data(New_path_data:Dictionary,The_Road:String) -> void:
	The_networks = {}
	var path_keys:Array = New_path_data.keys()
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
