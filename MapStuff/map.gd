extends Node2D
signal update_label
var path:PackedScene = preload("res://MapStuff/Path.tscn")
var Last_action: String = ""
enum{FIGHTER,INFLUENCE}
enum{BASE}
var Current_node: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func initialize(size:int) -> void:
	$UI.The_action.connect(Update_action)
	$UI.show()
	var num: int = 1 #iterator for name
	for child: Node in get_children(): #STAGE 1: NAMING NODES
		if child.is_in_group("MapNode"):
			child.name = str(num) #name all nodes
			child.A_node_clicked.connect(Check_node_action)
			for Astars: int in Overseer.player_list.size():
				Overseer.Logistics_array[Astars].add_point(num,child.position,0)
				Overseer.Intelligence_array[Astars].add_point(num,child.position,0)
			num+=1
			
	var generated_paths:Array
	for child: Node in get_children(): #STAGE 2: GENERATING PATHS
		if child.is_in_group("MapNode"):
			for value:int in Overseer.The_nodes[child.name]: 
				var constructed_name:String = child.name+"-"+str(value) #constructs name from node of origin and node it connects to 
				var reversed_constructed_name:String = str(value)+"-"+child.name
				if not (generated_paths.has(reversed_constructed_name) or generated_paths.has(constructed_name)) : #check if node exists already
					var new_path:Node = path.instantiate() #new path instance
					new_path.A_path_clicked.connect(Check_path_action)
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
	Last_action = action

func Check_node_action(Name: String) ->void:
	
	
	if Current_node:
		Current_node.remove_selection_circle()
	Current_node = find_child(Name)
	Current_node.add_selection_circle()
	
	$UI.find_child("Dynamic_Clicked").text = "Node " + Name #probably should be replaced with function call on UI instead of using find_child, ideally a universal update_UI(label, text) function to update any text in the UI.
	$UI.find_child("Dynamic_RPU").text = str(Current_node.node_RPU.RPU)
	$UI.find_child("Dynamic_Pop").text = str(Current_node.node_RPU.Population)
	
	if Last_action == "Base":
		#currently you can place bases on top of other bases.
		if Current_node.Has_building:
			$UI.action_error("there is already a base on this node!")
		elif Overseer.player_list[Overseer.selected_player_index].base_list.size() > 0:
			if Base_possible(Current_node.name) == true:
				#print("You have placed a base on node " + Name)
				Current_node.add_building(Overseer.player_list[Overseer.selected_player_index].Player_name, BASE)
				Current_node.Has_building = true
				find_child("Dynamic_Action").text = "None"
				Last_action = ""
			else:
				$UI.action_error("You do not have the conditions to place a Base!")
		elif Overseer.player_list[Overseer.selected_player_index].base_list.size() == 0:
			#print("You have placed a base on node " + Name)
			Current_node.add_building(Overseer.player_list[Overseer.selected_player_index].Player_name, BASE)
			Current_node.Has_building = true
			find_child("Dynamic_Action").text = "None"
			Last_action = ""

	if Last_action == "Fighter":
		if not Current_node.Has_building:
			$UI.action_error("Fighters must be placed at your own base")
		elif  Current_node.node_owner == Overseer.current_player:
			#print("You have placed a Fighter at a base on node " + Name)
			Current_node.add_unit(Overseer.current_player,FIGHTER)
			find_child("Dynamic_Action").text = "None"
			Last_action = ""

	if Last_action == "Influence":
		if Influence_possible(Current_node.name) == true:
			#print("You have placed a Influence on node " + Name)
			Current_node.add_unit("current_player",INFLUENCE)
			find_child("Dynamic_Action").text = "None"
			Last_action = ""
		else:
			$UI.action_error("Influence must be placed on a node connected to a base by Intelligence networks!")

func Check_path_action(Name: String) -> void:
	var Current_path: Node = find_child(Name)

	if Last_action == "Intelligence":
		if Current_path.Has_intel:
			$UI.action_error("there is already an Intelligence network on this path!")
		elif Intell_possible(Current_path.name) == true:
			#print("You have placed a Intelligence network on path " + Name)
			Current_path.add_intel_network()
			find_child("Dynamic_Action").text = "None"
			Current_path.Has_intel = true
			Intelligence_add_astar_path(Current_path.name)
			Last_action = ""
		else:
			$UI.action_error("You must place Intelligence networks next to an existing one!")

	if Last_action == "Logistics":
		if Current_path.Has_logs:
			$UI.action_error("there is already an Logistics network on this path!")
		elif Logs_possible(Current_path.name) == true:
			#print("You have placed a Logistics Network on path " + Name)
			Current_path.add_logistics_network()
			find_child("Dynamic_Action").text = "None"
			Current_path.Has_logs = true
			Logistics_add_astar_path(Current_path.name)
			Last_action = ""
		else:
			$UI.action_error("You must place Logistics Networks next to an existing one!")

func Logistics_add_astar_path(Road:String) -> void:
	var The_Roads: Array = Road.split("-")
	Overseer.Logistics_array[Overseer.selected_player_index].connect_points(int(The_Roads[0]),int(The_Roads[1]),true)
 
func Intelligence_add_astar_path(Road:String)-> void:
	var The_Roads: Array = Road.split("-")
	Overseer.Intelligence_array[Overseer.selected_player_index].connect_points(int(The_Roads[0]),int(The_Roads[1]),true)

func Base_possible(Desired:String)-> bool:
	for x:Resource in Overseer.player_list[Overseer.selected_player_index].base_list:
		var Existing:int = x.location
		if Overseer.Logistics_array[Overseer.selected_player_index].get_id_path(Existing,int(Desired),false).size() > 0 and Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(Existing,int(Desired),false).size() > 0:
			return true
	return false

func Intell_possible(Desired:String)-> bool:
	var The_Roads: Array = Desired.split("-")
	for x:Resource in Overseer.player_list[Overseer.selected_player_index].base_list:
		var Existing:int = x.location
		if Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(int(The_Roads[0]),Existing,false).size() > 0 or Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(int(The_Roads[1]),Existing,false).size() > 0:
			return true
	return false

func Logs_possible(Desired:String)-> bool:
	var The_Roads: Array = Desired.split("-")
	for x:Resource in Overseer.player_list[Overseer.selected_player_index].base_list:
		var Existing:int = x.location
		if Overseer.Logistics_array[Overseer.selected_player_index].get_id_path(int(The_Roads[0]),Existing,false).size() > 0 or Overseer.Logistics_array[Overseer.selected_player_index].get_id_path(int(The_Roads[1]),Existing,false).size() > 0:
			return true
	return false

func Influence_possible(Desired:String)-> bool:
	for x:Resource in Overseer.player_list[Overseer.selected_player_index].base_list:
		var Existing:int = x.location
		if Overseer.Intelligence_array[Overseer.selected_player_index].get_id_path(Existing,int(Desired),false).size() > 0: 
			return true
	return false
