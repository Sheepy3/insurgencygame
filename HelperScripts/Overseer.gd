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
signal toggle_ready(player:int)
signal update_combat(map_node_path:NodePath)


### COMBAT
var attacker_ready: bool = false
var defender_ready: bool = false
var attacking_player: int
var defending_player: int

enum RESOURCE_TYPE {NONE, WEAPONS,MONEY,MANPOWER} 
enum UNIT_TYPE {FIGHTER, INFLUENCE} 

var attacking_resource_type:int = RESOURCE_TYPE.NONE
var defending_resource_type:int = RESOURCE_TYPE.NONE
var attacking_resource_allocation:int = 0
var defending_resource_allocation:int = 0
var attacking_units:Array
var defending_units:Array
var map_node_path:NodePath
const DAMAGE_PER_EFFECT := 5.0

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
func Request_node_data(Edited_node_name:String,combat_data:Array = []) -> void:
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
		Update_node_data.rpc(Edited_node.name,New_node,combat_data)

@rpc("authority", "call_local", "reliable")
func Update_node_data(Edited_node_name:String,New_node_data:Dictionary,combat_data:Array = []) -> void:
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
		elif Placables.begins_with("Unit:"):
			Edited_node.add_unit(Values[3], Values[0], Values[4], Values[1])
			
			var updated_unit: Resource = Edited_node.unit_list[Edited_node.unit_list.size() - 1] #MONKEYPATCH PLUG IN THE MISSING VALUES
			updated_unit.unit_type = Values[0]
			updated_unit.unit_UUID = Values[1]
			updated_unit.disrupted = Values[2]
			updated_unit.player_ID = Values[3]
			updated_unit.color = Values[4]
			updated_unit.offcolor = Values[5]
			x += 1
	if !combat_data.is_empty():
		update_combat.emit(combat_data)

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

@rpc("any_peer", "call_local", "reliable")
func request_update_toggle(weapons:int,money:int, manpower:int) -> void:
	if multiplayer.is_server():
		var sender_id: int = multiplayer.get_remote_sender_id()
		if sender_id == 0:
			sender_id = multiplayer.get_unique_id()
		var sender:Resource = Identify_player(sender_id)
		if sender.Player_ID == attacking_player:
			attacker_ready = !attacker_ready
			if !attacker_ready:
				attacking_resource_type = RESOURCE_TYPE.NONE
				attacking_resource_allocation = 0
			else:
				if weapons > 0:
					attacking_resource_type = RESOURCE_TYPE.WEAPONS
					attacking_resource_allocation = weapons if sender.Weapons >= weapons else 0
				elif money > 0:
					attacking_resource_type = RESOURCE_TYPE.MONEY
					attacking_resource_allocation = money if sender.Money >= money else 0
				elif manpower > 0:
					attacking_resource_type = RESOURCE_TYPE.MANPOWER
					attacking_resource_allocation = manpower if sender.Man_power >= manpower else 0 
			print("attackers resources: " + str(attacking_resource_allocation))
			print("defenders resources: " + str(defending_resource_allocation))
			if defender_ready and attacker_ready:
				#sync_ready_state.rpc(attacker_ready, defender_ready, 0)
				# test uncommenting the above ^
				compute_consequences()
			else:
				sync_ready_state.rpc(attacker_ready, defender_ready, 0)

		elif sender.Player_ID == defending_player:
			defender_ready = !defender_ready
			if !defender_ready:
				defending_resource_type = RESOURCE_TYPE.NONE
				defending_resource_allocation = 0
			else:
				if weapons > 0:
					defending_resource_type = RESOURCE_TYPE.WEAPONS
					defending_resource_allocation = weapons if sender.Weapons >= weapons else 0
				elif money > 0:
					defending_resource_type = RESOURCE_TYPE.MONEY
					defending_resource_allocation = money if sender.Money >= money else 0
				elif manpower > 0:
					defending_resource_type = RESOURCE_TYPE.MANPOWER
					defending_resource_allocation = manpower if sender.Man_power >= manpower else 0 
			print("attackers resources: " + str(attacking_resource_allocation))
			print("defenders resources: " + str(defending_resource_allocation))
			if defender_ready and attacker_ready:
				sync_ready_state.rpc(attacker_ready, defender_ready, 1)
				compute_consequences()
			else:
				sync_ready_state.rpc(attacker_ready, defender_ready, 1)
			

@rpc("any_peer", "call_local", "reliable")
func sync_ready_state(new_attacker_ready: bool, new_defender_ready: bool, changed_player: int) -> void:
	attacker_ready = new_attacker_ready
	defender_ready = new_defender_ready
	toggle_ready.emit(changed_player)

func compute_consequences() -> void:
	print("combat start!")

	if attacking_resource_allocation <= 0 or defending_resource_allocation <= 0:
		print("Invalid combat allocation. Bets must be greater than 0.")
		reset_combat_state()
		return

	### Both sides pay their bet.
	var defending_player_resource:Resource = Identify_player(defending_player)
	var attacking_player_resource:Resource = Identify_player(attacking_player)
	
	if attacking_resource_type == RESOURCE_TYPE.MONEY:
		attacking_player_resource.Money -= attacking_resource_allocation
	elif attacking_resource_type == RESOURCE_TYPE.WEAPONS:
		attacking_player_resource.Weapons -= attacking_resource_allocation
	elif attacking_resource_type == RESOURCE_TYPE.MANPOWER:
		attacking_player_resource.Man_power -= attacking_resource_allocation
	
	if defending_resource_type == RESOURCE_TYPE.MONEY:
		defending_player_resource.Money -= defending_resource_allocation
	elif defending_resource_type == RESOURCE_TYPE.WEAPONS:
		defending_player_resource.Weapons -= defending_resource_allocation
	elif defending_resource_type == RESOURCE_TYPE.MANPOWER:
		defending_player_resource.Man_power -= defending_resource_allocation
		
	if attacking_resource_allocation == defending_resource_allocation:
		print("Combat tied. No consequences.")
		reset_combat_state()
		Resources_to_rpc()
		return

	var attacker_won := attacking_resource_allocation > defending_resource_allocation

	var winning_resource_type: int
	var losing_resource_type: int
	var winning_bet: int
	var losing_bet: int
	var winning_units: Array
	var losing_units: Array

	if attacker_won:
		winning_resource_type = attacking_resource_type
		losing_resource_type = defending_resource_type
		winning_bet = attacking_resource_allocation
		losing_bet = defending_resource_allocation
		winning_units = attacking_units
		losing_units = defending_units
	else:
		winning_resource_type = defending_resource_type
		losing_resource_type = attacking_resource_type
		winning_bet = defending_resource_allocation
		losing_bet = attacking_resource_allocation
		winning_units = defending_units
		losing_units = attacking_units

	var base_damage := float(winning_bet - losing_bet)
	var rps_multiplier := 1.0
	var winner_rps:bool = false

	#Rock-Paper-Scissors check
	if winning_resource_type == RESOURCE_TYPE.MONEY and losing_resource_type == RESOURCE_TYPE.WEAPONS:
		winner_rps = true
	if winning_resource_type == RESOURCE_TYPE.WEAPONS and losing_resource_type == RESOURCE_TYPE.MANPOWER:
		winner_rps = true
	if winning_resource_type == RESOURCE_TYPE.MANPOWER and losing_resource_type == RESOURCE_TYPE.MONEY:
		winner_rps = true

	if winner_rps:
		rps_multiplier = 1.5
	
	var unit_power := 0.0
	for unit: Resource in winning_units:
		if unit.unit_type == UNIT_TYPE.FIGHTER:
			unit_power += 1.0
		elif unit.unit_type == UNIT_TYPE.INFLUENCE:
			unit_power += 0.5
		print("unit type" + str(unit.unit_type))

	var final_damage := base_damage * rps_multiplier * unit_power

	print("Base damage: " + str(base_damage))
	print("RPS multiplier: " + str(rps_multiplier))
	print("Unit power: " + str(unit_power))
	print("Final damage: " + str(final_damage))

	var remaining_damage := final_damage

	# 1. Kill disrupted fighters first.
	remaining_damage = kill_units_by_filter(losing_units, remaining_damage, UNIT_TYPE.FIGHTER, true)

	# 2. Kill disrupted influence units.
	remaining_damage = kill_units_by_filter(losing_units, remaining_damage, UNIT_TYPE.INFLUENCE, true)

	# 3. Disrupt fresh fighters.
	remaining_damage = disrupt_units_by_filter(losing_units, remaining_damage, UNIT_TYPE.FIGHTER)

	# 4. Disrupt fresh influence units.
	remaining_damage = disrupt_units_by_filter(losing_units, remaining_damage, UNIT_TYPE.INFLUENCE)

	### actually update units on node and then send RPC to update display
	Resources_to_rpc()
	var map_node:Node = get_node(map_node_path)
	map_node.unit_list = losing_units + winning_units
	map_node.reorder_units()
	var winning_player:int
	if attacker_won:
		winning_player=1
	else:
		winning_player=0
		
	var combat_data:Array = [map_node_path,attacking_resource_type,attacking_resource_allocation,defending_resource_type,defending_resource_allocation,final_damage,winning_player]
	Request_node_data(map_node.name, combat_data)
	reset_combat_state()

func kill_units_by_filter(units: Array, damage: float, unit_type: int, must_be_disrupted: bool) -> float:
	var i := units.size() - 1

	while i >= 0 and damage >= DAMAGE_PER_EFFECT:
		var unit: Resource = units[i]

		if unit.unit_type == unit_type and unit.disrupted == must_be_disrupted:
			units.remove_at(i)
			damage -= DAMAGE_PER_EFFECT

		i -= 1

	return damage

func disrupt_units_by_filter(units: Array, damage: float, unit_type: int) -> float:
	for unit: Resource in units:
		if damage < DAMAGE_PER_EFFECT:
			break

		if unit.unit_type == unit_type and unit.disrupted == false:
			unit.disrupted = true
			damage -= DAMAGE_PER_EFFECT

	return damage

func reset_combat_state() -> void:
	attacker_ready = false
	defender_ready = false
	attacking_resource_type = RESOURCE_TYPE.NONE
	defending_resource_type = RESOURCE_TYPE.NONE
	attacking_resource_allocation = 0
	defending_resource_allocation = 0
	attacking_units = []
	defending_units = []
	map_node_path = NodePath("")
