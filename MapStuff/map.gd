extends Node2D
signal update_label
var path:PackedScene = preload("res://MapStuff/Path.tscn")
var Last_action: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI.The_action.connect(Update_action)
	var num: int = 1 #iterator for name
	for child: Node in get_children(): #STAGE 1: NAMING NODES
		if child is Node2D and child is not Camera2D:
			child.name = str(num) #name all nodes
			child.A_node_clicked.connect(Check_action)
			num+=1
	#print(get_children())
	var generated_paths:Array
	for child: Node in get_children(): #STAGE 2: GENERATING PATHS
		if child is Node2D and child is not Camera2D:
			for keys:int in The_nodes[child.name]: 
				var constructed_name:String = child.name+"-"+str(keys) #constructs name from node of origin and node it connects to 
				var reversed_constructed_name:String = str(keys)+"-"+child.name
				if not (generated_paths.has(reversed_constructed_name) or generated_paths.has(constructed_name)) : #check if node exists already

					var new_path:Node = path.instantiate() #new path instance
					new_path.connection = find_child(str(keys)).position #give new path coordinates to point to 
					new_path.name = constructed_name #set name of new path
					child.add_child(new_path) #add new path to scene as child of its origin node
					generated_paths.append(constructed_name)
	update_label.emit()

func Update_action(action: String = "") ->void:
	Last_action = action

func Check_action(Name: String) ->void:
	var Current_node: Node = find_child(Name)
	if Last_action == "Base":
		Current_node.On_node = "Base"
		print("You have placed a base on node " + Name)
		Current_node.find_child("Building").show()
		Current_node.Has_building = true
		find_child("Dynamic_Action").text = "None"
		print(Current_node.Has_building)
		Last_action = ""
	if Last_action == "Fighter" and  Current_node.Has_building:
		print("You have placed a Fighter at a base on node " + Name)
		Current_node.find_child("Fighter_Unit").show()
		find_child("Dynamic_Action").text = "None"
		Last_action = ""
		pass
	if Last_action == "Influence":
		print("You have placed a Influnce on node " + Name)
		Current_node.find_child("Influence_Unit").show()
		find_child("Dynamic_Action").text = "None"
		Last_action = ""
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# Define the graph as a dictionary where each node points to a list of connected nodes
# Note: this ought to be replaced with a more flexible system. 
const The_nodes = {
"1": [2, 4], 
"2": [1, 5],
"3": [4, 7],
"4": [1, 3, 8],
"5": [2, 6, 9],
"6": [5, 10],
"7": [3, 11],
"8": [4, 9, 12],
"9": [5, 8, 13],
"10": [6, 14],
"11": [7, 12, 15],
"12": [8, 11, 16],
"13": [9, 14, 17],
"14": [10, 13, 18],
"15": [11, 19],
"16": [12, 17, 20],
"17": [13, 16, 21],
"18": [14, 22],
"19": [15, 20],
"20": [16, 23],
"21": [17, 22, 24],
"22": [18, 21],
"23": [20, 24],
"24": [21, 23]
}

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
			for Adj: int in The_nodes.get(str(Position), []):
				if not Visited.has(Adj):
					# Adding the new adjacents to the visited list as a key, with their parent as a value 
					Visited[Adj] = Position  
					# Adds neighboring node to the queue
					The_que.append(Adj) 
	return{} #prevents error lol
