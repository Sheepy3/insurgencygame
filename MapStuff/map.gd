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
		Last_action = Action
		Current_player = Overseer.Identify_player(Player_ID) #Overseer.Identify_player(multiplayer.get_remote_sender_id())
		if Current_node:
			Current_node.remove_selection_circle()
		Current_node = find_child(Name)
		Current_node.add_selection_circle()
		print("This is the last action:"+ Last_action)
		$UI.find_child("Dynamic_Clicked").text = "Node " + Name #probably should be replaced with function call on UI instead of using find_child, ideally a universal update_UI(label, text) function to update any text in the UI.
		$UI.find_child("Dynamic_RPU").text = str(Current_node.node_RPU.RPU)
		$UI.find_child("Dynamic_Pop").text = str(Current_node.node_RPU.Population)
		if Last_action == "Base":
			print("client:"+str(Current_player.Player_ID)+"'s last action was:"+str(Last_action))
			#currently you can place bases on top of other bases.
			if Current_node.Has_building:
				$UI.action_error("there is already a base on this node!")
			elif Current_player.base_list.size() > 0:
				if Base_possible(Current_node.name) == true:
					#print("You have placed a base on node " + Name)
					Current_node.add_building(Current_player.Player_name, BASE, Current_player.color)
					Current_node.Has_building = true
					find_child("Dynamic_Action").text = "None"
					Last_action = ""
					Overseer.Request_node_data(Current_player,Current_node.name)
				else:
					$UI.action_error("You do not have the conditions to place a Base!")
			elif Current_player.base_list.size() == 0:
				#print("You have placed a base on node " + Name)
				Current_node.add_building(Current_player.Player_name, BASE, Current_player.color)
				Current_node.Has_building = true
				find_child("Dynamic_Action").text = "None"
				Last_action = ""
				#print(type_string(typeof(Current_node.name)))
				Overseer.Request_node_data(Current_player,Current_node.name)

		if Last_action == "Fighter":
			if not Current_node.Has_building:
				$UI.action_error("Fighters must be placed at your own base")
			elif  Current_node.node_owner == Current_player.Player_name:
				#print("You have placed a Fighter at a base on node " + Name)
				Current_node.add_unit(Current_player.Player_name,FIGHTER,Current_player.color)
				find_child("Dynamic_Action").text = "None"
				Last_action = ""
				Overseer.Request_node_data(Current_player,Current_node.name)

		if Last_action == "Influence":
			if Influence_possible(Current_node.name) == true:
				#print("You have placed a Influence on node " + Name)
				Current_node.add_unit(Current_player.Player_name,INFLUENCE,Current_player.color)
				find_child("Dynamic_Action").text = "None"
				Last_action = ""
				Overseer.Request_node_data(Current_player,Current_node.name)
			else:
				$UI.action_error("Influence must be placed on a node connected to a base by Intelligence networks!")

@rpc("any_peer","call_local")
func Check_path_action(Name: String,Player_ID:int,Action:String) -> void:
	if multiplayer.is_server():
		Last_action = Action
		Current_player = Overseer.Identify_player(Player_ID)
		var Current_path: Node = find_child(Name)
		if Last_action == "Intelligence":
			if Current_path.Has_intel:
				$UI.action_error("there is already an Intelligence network on this path!")
			elif Intell_possible(Current_path.name) == true:
				#print("You have placed a Intelligence network on path " + Name)
				Current_path.add_intel_network(Current_player.color)
				find_child("Dynamic_Action").text = "None"
				Current_path.Has_intel = true
				Intelligence_add_astar_path(Current_path.name)
				Last_action = ""
				Overseer.Request_path_data(Current_player,Current_path.name)
			else:
				$UI.action_error("You must place Intelligence networks next to an existing one!")

		if Last_action == "Logistics":
			if Current_path.Has_logs:
				$UI.action_error("there is already an Logistics network on this path!")
			elif Logs_possible(Current_path.name) == true:
				#print("You have placed a Logistics Network on path " + Name)
				Current_path.add_logistics_network(Current_player.color)
				find_child("Dynamic_Action").text = "None"
				Current_path.Has_logs = true
				Logistics_add_astar_path(Current_path.name)
				Last_action = ""
				Overseer.Request_path_data(Current_player,Current_path.name)
			else:
				$UI.action_error("You must place Logistics Networks next to an existing one!")

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
	#print("_______________________")
	#print(Overseer.The_networks)
	#print(Overseer.The_networks[Current_player.Player_ID])
	#print(Overseer.The_networks[Current_player.Player_ID][0])
	#print("_______________________")
	var intel_map:AStar2D = Overseer.The_networks[Current_player.Player_ID][0]
	for x:Resource in Current_player.base_list:
		var Existing:int = x.location
		if intel_map.get_id_path(int(The_Roads[0]),Existing,false).size() > 0 or intel_map.get_id_path(int(The_Roads[1]),Existing,false).size() > 0:
		#Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(int(The_Roads[0]),Existing,false).size() > 0 or Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(int(The_Roads[1]),Existing,false).size() > 0:
			return true
	return false

func Logs_possible(Desired:String)-> bool:
	var The_Roads: Array = Desired.split("-")
	#print("_______________________")
	#print(Overseer.The_networks)
	#print(Overseer.The_networks[Current_player.Player_ID])
	#print(Overseer.The_networks[Current_player.Player_ID][1])
	#print("_______________________")
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

func Call_rpc_functions(Name:String,Player_ID:int,Tile:String) -> void:
	var Action:String = Last_action
	if Tile == "Node":
		Check_node_action.rpc(Name,Player_ID,Action)
	else:
		Check_path_action.rpc(Name,Player_ID,Action)
