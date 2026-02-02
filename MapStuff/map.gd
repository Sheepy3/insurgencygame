extends Node2D
signal update_label
var path:PackedScene = preload("res://MapStuff/Path.tscn")
var Last_action: String = ""
enum{FIGHTER,INFLUENCE}
enum{BASE}
var Current_node: Node
var Current_player:Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Flare") && Current_node && Current_node.is_in_group("MapNode"):
		Current_node.flare.rpc(multiplayer.get_unique_id())

func initialize(size:int) -> void:
	Current_player = Overseer.Identify_player(multiplayer.get_unique_id())
	$UI.The_action.connect(Update_action)
	$UI.show()
	var num: int = 1 #iterator for name
	for child: Node in get_children(): #STAGE 1: NAMING NODES
		if child.is_in_group("MapNode"):
			child.name = str(num) #name all nodes
			child.A_node_clicked.connect(Call_rpc_functions)
			for keys:int in Overseer.The_networks:
				var networks_array:Array = Overseer.The_networks[keys]
				var logistics_network:AStar2D = networks_array[0] 
				var intelligence_network:AStar2D = networks_array[1]
				logistics_network.add_point(num,child.position,0)
				intelligence_network.add_point(num,child.position,0)
			num+=1
			
	var generated_paths:Array
	for child: Node in get_children(): #STAGE 2: GENERATING PATHS
		if child.is_in_group("MapNode"):
			for value:int in Overseer.The_nodes[child.name]: 
				var constructed_name:String = child.name+"-"+str(value) #constructs name from node of origin and node it connects to 
				var reversed_constructed_name:String = str(value)+"-"+child.name
				if not (generated_paths.has(reversed_constructed_name) or generated_paths.has(constructed_name)) : #check if node exists already
					var new_path:Node = path.instantiate() #new path instance
					new_path.A_path_clicked.connect(Call_rpc_functions)
					new_path.connection = find_child(str(value)).position #give new path coordinates to point to 
					new_path.name = constructed_name #set name of new path
					new_path.add_to_group("Paths")
					child.add_child(new_path) #add new path to scene as child of its origin node
					new_path.set_owner(child)
					generated_paths.append(constructed_name)
	update_label.emit()

	match size:
		0:
			var board_texture:Texture2D = load("res://Assets/Board_tiny.webp")
			$Board.set_texture(board_texture)
		1:
			var board_texture:Texture2D = load("res://Assets/Board_small.webp")
			$Board.set_texture(board_texture)
		2:
			var board_texture:Texture2D = load("res://Assets/Board_normal.webp")
			$Board.set_texture(board_texture)
		3:
			var board_texture:Texture2D = load("res://Assets/Board_large.webp")
			$Board.set_texture(board_texture)

func Update_action(action: String = "") ->void:
	#Current_player = Overseer.Identify_player(multiplayer.get_unique_id())
	Last_action = action

@rpc("any_peer","call_local")
func Check_node_action(Name: String,Player_ID:int,Action:String) ->void:
	if multiplayer.is_server():
		var new_unit_UUID:String
		Last_action = Action
		Current_player = Overseer.Identify_player(Player_ID)
		#if Current_node:
		Current_node = find_child(Name)
		
		if Last_action.begins_with("move_fighter_"):
			var unpacked_node:int = int(Last_action.right(5))
			
			print("moving fighter from " + str(unpacked_node) + " to " + Name)
			var source_node:Node = find_child(str(unpacked_node))
			if source_node && source_node.has_unit(Current_player.Player_ID, FIGHTER):
				if Fighter_movement_possible(int(Name),unpacked_node,Player_ID):
					Last_action = ""
					new_unit_UUID = Overseer.Create_unique_ID()
					Current_node.add_unit(Current_player.Player_ID,FIGHTER,Current_player.color,new_unit_UUID)
					source_node.remove_unit(Current_player.Player_ID,FIGHTER)
					Overseer.Request_node_data(Current_node.name)
					Overseer.Request_node_data(source_node.name)
					Overseer.Resources_to_rpc()
			else:
				display_action_error("No fighter found at source node!",Player_ID)
				print("No fighter found at node " + str(unpacked_node) + " for player " + str(Current_player.Player_ID))
		
		if Last_action.begins_with("move_influence_"):
			var unpacked_node:int = int(Last_action.right(5))
			print("moving influence from " + str(unpacked_node) + " to " + Name)
			var source_node:Node = find_child(str(unpacked_node))
			if source_node && source_node.has_unit(Current_player.Player_ID, INFLUENCE):
				if Influence_movement_possible(int(Name),unpacked_node,Player_ID):
					Last_action = ""
					new_unit_UUID = Overseer.Create_unique_ID()
					Current_node.add_unit(Current_player.Player_ID,INFLUENCE,Current_player.color,new_unit_UUID)
					source_node.remove_unit(Current_player.Player_ID,INFLUENCE)
					Overseer.Request_node_data(Current_node.name)
					Overseer.Request_node_data(source_node.name)
					Overseer.Resources_to_rpc()
			else:
				display_action_error("No influence found at source node!",Player_ID)
				print("No influence found at node " + str(unpacked_node) + " for player " + str(Current_player.Player_ID))

		if Last_action == "Base_placing" && Current_player.Player_storage["Military_Base"] >= 1:
			if Current_node.Has_building:
				display_action_error("There is already a base on this node!",Player_ID)
			#elif Current_player.base_list.size() > 0:
			elif Base_possible(Current_node.name) == true:
				Current_node.add_building(Current_player.Player_ID, BASE, Current_player.color)
				#find_child("Dynamic_Action").text = "None"
				Last_action = ""
				Current_player.Player_storage["Military_Base"] -= 1
				Overseer.Request_node_data(Current_node.name)
				Overseer.Resources_to_rpc()
			elif Current_player.base_list.size() == 0 && Current_player.Player_storage["Military_Base"] >= 1:
				#print("You have placed a base on node " + Name)
				Current_node.add_building(Current_player.Player_ID, BASE, Current_player.color)
				#find_child("Dynamic_Action").text = "None"
				Last_action = ""
				Current_player.Player_storage["Military_Base"] -= 1
				#print(type_string(typeof(Current_node.name)))
				Overseer.Request_node_data(Current_node.name)
				Overseer.Resources_to_rpc()
			else:
				display_action_error("You do not have the conditions to place a Base!",Player_ID)
		elif Last_action == "Base_placing" && Current_player.Player_storage["Military_Base"] < 1:
			display_action_error("You do not have any Military Bases to place!",Player_ID)

		if Last_action == "Fighter_placing" && Current_player.Player_storage["Fighter"] >= 1:
			if Fighter_possible(Current_node.name) == false:
				display_action_error("Fighters must be placed at your own base!",Player_ID)
			elif  Fighter_possible(Current_node.name) == true:
				#print("You have placed a Fighter at a base on node " + Name)
				new_unit_UUID = Overseer.Create_unique_ID()
				Current_node.add_unit(Current_player.Player_ID,FIGHTER,Current_player.color,new_unit_UUID)
				#find_child("Dynamic_Action").text = "None"
				Last_action = ""
				Current_player.Player_storage["Fighter"] -= 1
				Overseer.Request_node_data(Current_node.name)
				Overseer.Resources_to_rpc()
		elif Last_action == "Fighter_placing" && Current_player.Player_storage["Fighter"] < 1:
			display_action_error("You do not have any Fighter units to place!",Player_ID)

		if Last_action == "Influence_placing" && Current_player.Player_storage["Influence"] >= 1:
			if Influence_possible(Current_node.name) == true:
				#print("You have placed a Influence on node " + Name)
				new_unit_UUID = Overseer.Create_unique_ID()
				Current_node.add_unit(Current_player.Player_ID,INFLUENCE,Current_player.color,new_unit_UUID)
				#find_child("Dynamic_Action").text = "None"
				Last_action = ""
				Current_player.Player_storage["Influence"] -= 1
				Overseer.Request_node_data(Current_node.name)
				Overseer.Resources_to_rpc()
			else:
				display_action_error("Influence must be placed on a node connected to a base by Intelligence networks!",Player_ID)
		elif Last_action == "Influence_placing" && Current_player.Player_storage["Influence"] < 1:
			display_action_error("You do not have any Influence units to place!",Player_ID)

@rpc("any_peer","call_local")
func Check_path_action(Name: String,Player_ID:int,Action:String) -> void:
	if multiplayer.is_server():
		Last_action = Action
		Current_player = Overseer.Identify_player(Player_ID)
		var Current_path: Node = find_child(Name)
		if Last_action == "Intel_placing" && Current_player.Player_storage["Intelligence"] >= 1:
			if Current_path.Has_intel:
				display_action_error("There is already an Intelligence Network on this path!",Player_ID)
			elif Intell_possible(Current_path.name) == true:
				#print("You have placed a Intelligence network on path " + Name)
				Current_path.add_intel_network(Current_player.color)
				#find_child("Dynamic_Action").text = "None"
				Current_path.Has_intel = true
				Intelligence_add_astar_path(Current_path.name)
				Last_action = ""
				Current_player.Player_storage["Intelligence"] -= 1
				Overseer.Request_path_data(Current_player,Current_path.name)
				Overseer.Resources_to_rpc()
			else:
				display_action_error("You must place Intelligence Networks next to an existing one!",Player_ID)
		elif Last_action == "Intel_placing" && Current_player.Player_storage["Intelligence"] < 1:
			display_action_error("You do not have any Intelligence Networks to place!",Player_ID)

		if Last_action == "Logs_placing" && Current_player.Player_storage["Logistics"] >= 1:
			if Current_path.Has_logs:
				display_action_error("There is already an Logistics Network on this path!",Player_ID)
			elif Logs_possible(Current_path.name) == true:
				#print("You have placed a Logistics Network on path " + Name)
				Current_path.add_logistics_network(Current_player.color)
				#find_child("Dynamic_Action").text = "None"
				Current_path.Has_logs = true
				Logistics_add_astar_path(Current_path.name)
				Last_action = ""
				Current_player.Player_storage["Logistics"] -= 1
				Overseer.Request_path_data(Current_player,Current_path.name)
				Overseer.Resources_to_rpc()
			else:
				display_action_error("You must place Logistics Networks next to an existing one!",Player_ID)
		elif Last_action == "Logs_placing" && Current_player.Player_storage["Logistics"] < 1:
			display_action_error("You do not have any Logistics Networks to place!",Player_ID)

func Logistics_add_astar_path(Road:String) -> void:
	var The_Roads: Array = Road.split("-")
	var logs_map:AStar2D = Overseer.The_networks[Current_player.Player_ID][1]
	logs_map.connect_points(int(The_Roads[0]),int(The_Roads[1]),true)
	#Overseer.Logistics_array[Overseer.selected_player_index].connect_points(int(The_Roads[0]),int(The_Roads[1]),true)

func Intelligence_add_astar_path(Road:String)-> void:
	var The_Roads: Array = Road.split("-")
	var intel_map:AStar2D = Overseer.The_networks[Current_player.Player_ID][0]
	intel_map.connect_points(int(The_Roads[0]),int(The_Roads[1]),true)
	#Overseer.Intelligence_array[Overseer.selected_player_index].connect_points(int(The_Roads[0]),int(The_Roads[1]),true)

func Base_possible(Desired:String)-> bool:
	if Current_node.Has_building == true:
		return false
	else:
		for x:Resource in Current_player.base_list:
			var Existing:int = x.location
			var intel_map:AStar2D = Overseer.The_networks[Current_player.Player_ID][0]
			var logs_map:AStar2D = Overseer.The_networks[Current_player.Player_ID][1]
			if logs_map.get_id_path(Existing,int(Desired),false).size() > 0 and intel_map.get_id_path(Existing,int(Desired),false).size() > 0:
			#Overseer.Logistics_array[Overseer.selected_player_index].get_id_path(Existing,int(Desired),false).size() > 0 and Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(Existing,int(Desired),false).size() > 0:
				return true
	return false

func Intell_possible(Desired:String)-> bool:
	var The_Roads: Array = Desired.split("-")
	var intel_map:AStar2D = Overseer.The_networks[Current_player.Player_ID][0]
	for x:Resource in Current_player.base_list:
		var Existing:int = x.location
		if intel_map.get_id_path(int(The_Roads[0]),Existing,false).size() > 0 or intel_map.get_id_path(int(The_Roads[1]),Existing,false).size() > 0:
		#Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(int(The_Roads[0]),Existing,false).size() > 0 or Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(int(The_Roads[1]),Existing,false).size() > 0:
			return true
	return false

func Logs_possible(Desired:String)-> bool:
	var The_Roads: Array = Desired.split("-")
	var logs_map:AStar2D = Overseer.The_networks[Current_player.Player_ID][1]
	for x:Resource in Current_player.base_list:
		var Existing:int = x.location
		if logs_map.get_id_path(int(The_Roads[0]),Existing,false).size() > 0 or logs_map.get_id_path(int(The_Roads[1]),Existing,false).size() > 0:
		#Overseer.Logistics_array[Overseer.selected_player_index].get_id_path(int(The_Roads[0]),Existing,false).size() > 0 or Overseer.Logistics_array[Overseer.selected_player_index].get_id_path(int(The_Roads[1]),Existing,false).size() > 0:
			return true
	return false

func Influence_possible(Desired:String)-> bool:
	for x:Resource in Current_player.base_list:
		var intel_map:AStar2D = Overseer.The_networks[Current_player.Player_ID][0]
		var Existing:int = x.location
		if intel_map.get_id_path(Existing,int(Desired),false).size() > 0: 
		#Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(Existing,int(Desired),false).size() > 0: 
			return true
	return false

func Fighter_possible(Node_name:String) -> bool:
	var Targeted_node:Node = find_child(Node_name)
	if Targeted_node.Has_building && Targeted_node.building.color == Current_player.color:
		return true
	return false

func Fighter_movement_possible(from:int, to:int, Player_ID:int) -> bool:
	var logs_map:AStar2D = Overseer.The_networks[Player_ID][1]
	var intel_map:AStar2D = Overseer.The_networks[Player_ID][0]
	
	var logs_pathfind:int = logs_map.get_id_path(from,to,false).size()
	var intel_pathfind:int = intel_map.get_id_path(from,to,false).size()
	
	if (intel_pathfind <= 3) and (logs_pathfind <= 3):
		if  (intel_pathfind > 0) and (logs_pathfind > 0):
			return true
		else:
			display_action_error("Fighters can only move to nodes connected by logi. and intel networks!", Player_ID)
			return false
	else:
		display_action_error("Fighters can only move 2 nodes!", Player_ID)
		return false
	

func Influence_movement_possible(from:int, to:int, Player_ID:int) -> bool:
	var intel_map:AStar2D = Overseer.The_networks[Player_ID][0]
	var intel_pathfind:int = intel_map.get_id_path(from,to,false).size()
	
	if (intel_pathfind <= 2):
		if  (intel_pathfind > 0):
			return true
		else:
			display_action_error("Influence can only move to nodes connected by intel networks!", Player_ID)
			return false
	else:
		display_action_error("Influence can only move 1 node!", Player_ID)
		return false
	

func Call_rpc_functions(Name:String,Player_ID:int,Tile:String) -> void:
	if Current_node:
		Current_node.remove_selection_circle()
	if !Last_action && Tile == "Node":
		Current_node = find_child(Name)
		Current_node.add_selection_circle()
	else:
		Current_node = null
		if Tile == "Node":
			Check_node_action.rpc(Name,Player_ID,Last_action)
			Last_action = ""
			find_child("Dynamic_Action").text = "None"
		else:
			Check_path_action.rpc(Name,Player_ID,Last_action)
			Last_action = ""
			find_child("Dynamic_Action").text = "None"

func display_action_error(the_error:String, Player_ID:int) -> void:
	$UI.action_error.rpc(the_error,Player_ID)
	Last_action = ""
