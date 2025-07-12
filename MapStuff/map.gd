extends Node2D
signal update_label
var path:PackedScene = preload("res://MapStuff/Path.tscn")
var Last_action: String = ""
enum{FIGHTER,INFLUENCE}
enum{BASE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI.The_action.connect(Update_action)
	var num: int = 1 #iterator for name
	for child: Node in get_children(): #STAGE 1: NAMING NODES
		if child is Node2D and child is not Camera2D and child is not Sprite2D:
			child.name = str(num) #name all nodes
			child.A_node_clicked.connect(Check_node_action)
			#Overseer.Mind_map.add_point(num,child.position,0)
			Overseer.Logistics_map.add_point(num,child.position,0)
			Overseer.Intelligence_map.add_point(num,child.position,0)
			num+=1
	var generated_paths:Array
	for child: Node in get_children(): #STAGE 2: GENERATING PATHS
		if child is Node2D and child is not Camera2D and child is not Sprite2D:
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
	#Generate_mind() [for possible future use...]

func Update_action(action: String = "") ->void:
	Last_action = action

func Check_node_action(Name: String) ->void:
	var Current_node: Node = find_child(Name)
	#print(Current_node)

	if Last_action == "Base":
		#currently you can place bases on top of other bases.
		if Current_node.Has_building:
			$UI.action_error("there is already a base on this node!")
		elif Overseer.base_list.size() > 0:
			if Base_possible(Current_node.name) == true:
				#Current_node.On_node = "Base"
				print("You have placed a base on node " + Name)
				Current_node.add_building(Overseer.current_player, BASE)
				#Current_node.find_child("Building").show()
				Current_node.Has_building = true
				find_child("Dynamic_Action").text = "None"
				#print(Current_node.Has_building)
				Last_action = ""
		elif Overseer.base_list.size() == 0:
			print("You have placed a base on node " + Name)
			Current_node.add_building(Overseer.current_player, BASE)
			Current_node.Has_building = true
			find_child("Dynamic_Action").text = "None"
			Last_action = ""

	if Last_action == "Fighter":
		if not Current_node.Has_building:
			$UI.action_error("Fighters must be placed at your own base")
		if  Current_node.node_owner == Overseer.current_player:
			print("You have placed a Fighter at a base on node " + Name)
			Current_node.add_unit(Overseer.current_player,FIGHTER)
			#Current_node.find_child("Fighter_Unit").show()
			find_child("Dynamic_Action").text = "None"
			Last_action = ""
		else:
			$UI.action_error("Fighters must be placed at your own base")

	if Last_action == "Influence":

		print("You have placed a Influnce on node " + Name)
		Current_node.add_unit("current_player",INFLUENCE)
		#Current_node.find_child("Influence_Unit").show()

		find_child("Dynamic_Action").text = "None"
		Last_action = ""

func Check_path_action(Name: String) -> void:
	var Current_path: Node = find_child(Name)

	#var Path_parent_array: Array = Name.split("-")
	#var Path_parent: Node = find_child(Path_parent_array[0])
	#var Current_path: Node 
	#for child in Path_parent.get_children():
	#	if child.name == Name:
	#		Current_path = child
	
	# need to update this when new network system implemented


	if Last_action == "Intelligence":
		print("You have placed a Intelligence Network on path " + Name)
		Current_path.add_intel_network(Overseer.current_player)
		#var path_to_edit:Node = Current_path.find_child("Intelligence_Network")
		#path_to_edit.show()
		#path_to_edit.material.set_shader_parameter("tint_color", Overseer.players_colors[Overseer.selected_player_index])
		find_child("Dynamic_Action").text = "None"
		Current_path.Has_intel = true
		Intelligence_add_astar_path(Current_path.name)
		Last_action = ""
		
	if Last_action == "Logistics":
		print("You have placed a Logistics Network on path " + Name)
		Current_path.add_logistics_network(Overseer.current_player)
		#var path_to_edit:Node = Current_path.find_child("Logistics_Network")
		#path_to_edit.show()
		#path_to_edit.material.set_shader_parameter("tint_color", Overseer.players_colors[Overseer.selected_player_index])
		#path_to_edit.
		find_child("Dynamic_Action").text = "None"
		Current_path.Has_logs = true
		Logistics_add_astar_path(Current_path.name)
		Last_action = ""


# Define the graph as a dictionary where each node points to a list of connected nodes
# Note: this ought to be replaced with a more flexible system. 


func Pathfind(Start: int, End: int)-> Dictionary: #BFS algorithm
# initializing initial variables (que, list of visited nodes, current position in the que
	var The_que: Array = []
	var Visited: Dictionary = {}
	# adds the starting place to visited places
	Visited[Start] = ""  
	The_que.append(Start)
	#continues the search until “The_que” has been emptied
	while The_que.size() > 0:
		var Position: int = The_que.pop_front()
		# When sertch reatches "End" number returs the path  
		if Position == End:
			var Route: Array = []
			while Position != Start:
				Route.append(Position)
				Position = Visited.get(Position)
			#Takes the path and transforms it from End -> Start to Start -> End 
			Route.append(Start)
			Route.reverse()
			# Return the optimal route and length 
			return {"path": Route, "length": Route.size()}
		else: 
			# Explores the other nodes that are directly connected to current node
			for Adj: int in Overseer.The_nodes.get(str(Position), []):
				if not Visited.has(Adj):
					# Adding the new adjacents to the visited list as a key, with their parent as a value 
					Visited[Adj] = Position  
					# Adds neighboring node to the queue
					The_que.append(Adj) 
	return{} #prevents error lol

#Origional idea for base placing logic
#func Path_check(Desired: Node) ->bool:
	#var The_que: Array = []
	#var Visited: Dictionary = {}
	#var Route: Array = [""]
	#var x: int = 0
	#Visited[Desired] = ""
	#The_que.append(Desired)
	#while The_que.size() > 0:
		#var Position: Node = The_que.pop_front()
		#for Spots: Node in get_children(): 
			#if Spots is Node2D and Spots is not Camera2D or CanvasLayer:
				#print(Spots.name)
				#for Paths: Node in Spots.get_children():
					#if Paths is Node2D and Paths.is_in_group("Paths"):
						##var micro_child: Node = find_child("Intelligence_Network")
						#print(Paths.name)
						#if Paths.Has_intel == true:
							#The_que.append(Paths)
							#Route[x] = Paths.name
							#x += x
							#print(Route) 
		#pass
	#return false
	
#Below is for possible future use
#func Generate_mind() -> void: 
	#for x:String in Overseer.The_nodes.keys(): 
		#for y:int in Overseer.The_nodes[x]:
			#Overseer.Mind_map.connect_points(int(x),y,true)
	#print(Overseer.Mind_map.get_id_path(1,24))

func Logistics_add_astar_path(Road:String) -> void:
	var The_Roads: Array = Road.split("-")
	Overseer.Logistics_map.connect_points(int(The_Roads[0]),int(The_Roads[1]),true)
	Overseer.The_nodes.values()
	 
func Intelligence_add_astar_path(Road:String)-> void:
	var The_Roads: Array = Road.split("-")
	Overseer.Intelligence_map.connect_points(int(The_Roads[0]),int(The_Roads[1]),true)
	Overseer.The_nodes.values()

func Base_possible(Desired:String)-> bool:
	for x:Resource in Overseer.base_list:
		var Existing:int = x.location
		if Overseer.Logistics_map.get_id_path(Existing,int(Desired),false).size() > 0 and Overseer.Intelligence_map.get_id_path(Existing,int(Desired),false).size() > 0:
			return true
	return false
