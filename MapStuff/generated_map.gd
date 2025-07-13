extends Node
var testhex:PackedScene = preload("res://MapStuff/TEST_Hex.tscn")
var testdot:PackedScene = preload("res://MapStuff/Map_Node.tscn")
#@export var s:int
@export var size:int =1

func _ready() -> void:
	var sum_points:Array
	var centers := hex_centers(size, 360)  # e.g. N=1 ring, s= center to vertex distance
	for i in range(centers.size()):
		var v:Vector2 = centers[i]
		var new_hex:Node = testhex.instantiate()
		#new_hex.position = v
		#add_child(new_hex)
		var points := vertices(v,360)
		sum_points.append_array(points)
		
	var sum_points_pruned:Array
	for point:Vector2 in sum_points:
		var V:Vector2 = Vector2(
				round(point.x), # converts all x coordinates to integers so they aren't weird anymore
				round(point.y) # this removes error in the y-axis by resetting the y point to an integer and then re-multiplying by h.
			)
		
		var unique:bool = true
		for q:Vector2 in sum_points_pruned:
			if V in sum_points_pruned:
				unique = false
		if unique:
			sum_points_pruned.append(V)
	sum_points_pruned.sort_custom(func(a:Vector2, b:Vector2)-> bool:
		if a.y < b.y:           # clearly above → comes first
			return true
		if a.y > b.y:           # clearly below → comes after
			return false
		return a.x < b.x        # same row → left-to-right
	)
	for o in range(sum_points_pruned.size()):
		var new_dot:Node = testdot.instantiate()
		new_dot.name = str((o+1))
		new_dot.position = sum_points_pruned[o]
		new_dot.find_child("Label").text = str(o+1)
		get_parent().add_child(new_dot)
		new_dot.set_owner(get_parent())
	var the_nodes:Dictionary
	for key: Node in get_parent().get_children():
		if key is Node2D and key is not Camera2D and key is not Sprite2D:
			#var base:Node = find_child("3")
			#print(base.position.distance_squared_to(key.position))
			var connections:Array
			for value:Node in get_parent().get_children():
				if value is Node2D and value is not Camera2D and value is not Sprite2D:
					if key.position.distance_squared_to(value.position) < 130000 and key.position.distance_squared_to(value.position) != 0:
						connections.append(int(value.name))
			the_nodes[str(key.name)] = connections
	Overseer.The_nodes = the_nodes
	print(Overseer.The_nodes)
	get_parent()._initialize()


#generates virtual hexagons 
func hex_centers(n: int, s: float) -> Array:
	#var s:float = 2.0 * R / sqrt(3.0) 
	var coords: Array = []
	# Loop axial coords q,r_axial such that distance <= n
	for q in range(-n, n + 1):
		var r1:int = max(-n, -q - n)
		var r2:int = min(n, -q + n)
		for r_axial in range(r1, r2 + 1):
			# flat-topped conversion
			var x:float = s * 1.5 * q
			var y:float = s * sqrt(3) * (r_axial + q * 0.5)
			coords.append(Vector2(x, y))
	return coords

func vertices(origin:Vector2, s:int) -> Array:
	var h:float = s*sqrt(3) / 2
	#print(a)
	var vertices:Array = []
	
	vertices.append(origin+Vector2((-s/2),h))
	vertices.append(origin+Vector2((s/2),h))
	vertices.append(origin+Vector2(s,0))
	vertices.append(origin+Vector2((s/2),-h))
	vertices.append(origin+Vector2((-s/2),-h))
	vertices.append(origin+Vector2(-s,0))
	return vertices
