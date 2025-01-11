extends Node2D



# Declares dictionary of nodes and fellow nodes they are connected to. 
const The_nodes = {
	"1": [2,4], 
	"2": [1,5],
	"3": [4,7],
	"4": [1,3,8],
	"5": [2,6,9],
	"6": [5,10],
	"7": [3,11],
	"8": [4,9,12],
	"9": [5,8,13],
	"10": [6,14],
	"11": [7,12,15],
	"12": [8,11,16],
	"13": [9,14,17],
	"14": [10,13,18],
	"15": [11,19],
	"16": [12,17,20],
	"17": [13,16,21],
	"18": [14,22],
	"19": [15,20],
	"20": [16,23],
	"21": [17,22,24],
	"22": [18,21],
	"23": [20,24],
	"24": [21,23],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

#Takes imput from current position and desired psoition
#Returns the most optimal path from currnet to desired
#func Traverse(Start,End):
	#
	#
	##var Route = []  
	##var Route_len = Route.lenth
	##var The_que = []
	##var Visited = {}
	##The_que.append(start)
	##visited[start] = " "
	##while The_que.size() > 0:
		##var Next = The_que.pop_front()
		##if Next == End:
			
		
		
func Traverse_test(Start: int, End: int) -> Dictionary:
# initializing initial variables (que, list of visited nodes, current position in the que
	var The_que: Array = []
	var Visited: Dictionary = {}
	# adds the starting place to visited places
	Visited[Start] = ""  
	The_que.append(Start)
#continues the search until “The_que” has been emptied
	while The_que.size() > 0:
		var Position: int = The_que.pop_front()
		# 
		if Position == End:
			var Route: Array = []
			var node: int = Position
			while str(node) != "":
				Route.append(node)
				node = Visited[node]
#Takes the path and transforms it from End -> Start to Start -> End 
			Route.reverse()  
# Return the optimal route and length 
			return {"path": Route, "length": Route.size()}
# Explores the other nodes that are directly connected to current node
		for Adj: int in The_nodes.get(Position, []):
			if not Visited.has(Adj):
				# Mark neighbor node as visited
				Visited[Adj] = Position  
				# Adds neighboring node to the queue
				The_que.append(Adj)  
	return {}
