extends Node

@export var size:int 

func _ready() -> void:
	
	var node_data:Dictionary
	var hex_data:Dictionary	
	var sum_points:Array
	var sum_points_pruned:Array
	
	var centers := hex_centers(size, 280)  # e.g. N=1 ring, s= center to vertex distance
	
	for i in range(centers.size()):
		hex_data[str(i)] = centers[i]
		var v:Vector2 = centers[i]
		var points := vertices(v,280)
		sum_points.append_array(points)
		
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
		node_data[str((o+1))] = sum_points_pruned[o]
		
	get_parent().find_child("MapBuilder").build_map(node_data,hex_data,size)

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
