extends Node2D
signal update_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var num: int = 1
	for child: Node in get_children():
		if child is not Camera2D:
			child.name = str(num)
			num+=1
	update_label.emit()
	print(Traverse_test(1, 19))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
# Define the graph as a dictionary where each node points to a list of connected nodes
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
func Traverse_test(Start: int, End: int)-> Dictionary:
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
			print(Position)
			var Route: Array = []
			while Position != Start:
				print(Position)
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
	return{}
