extends Node2D
var testhex:PackedScene = preload("res://MapStuff/TEST_Hex.tscn")
var testdot:PackedScene = preload("res://MapStuff/TEST_DOT.tscn")
@export var s:int

func _ready() -> void:
	var sum_points:Array
	var centers := hex_centers(1, s)  # e.g. N=1 ring, R=10
	for i in range(centers.size()):
		var v:Vector2 = centers[i]
		#print("Hex %d: x=%f, y=%f" % [i, v.x, v.y])
		var new_hex:Node = testhex.instantiate()
		new_hex.position = v
		add_child(new_hex)
		var points := vertices(new_hex.position,s)
		sum_points.append_array(points)
		
	var sum_points_pruned:Array
	for point:Vector2 in sum_points:
		var unique:bool = true
		for q:Vector2 in sum_points_pruned:
			print(point.distance_squared_to(q))
			if point.distance_squared_to(q) < 0.25:
				unique = false
		if unique:
			sum_points_pruned.append(point)
	sum_points_pruned.sort_custom(func(a:Vector2, b:Vector2)-> bool:
		if a.y < b.y:           # clearly above → comes first
			return true
		if a.y > b.y:           # clearly below → comes after
			return false
		return a.x < b.x        # same row → left-to-right
)
	print(sum_points_pruned)
	for o in range(sum_points_pruned.size()):
		var new_dot:Node = testdot.instantiate()
		new_dot.position = sum_points_pruned[o]
		new_dot.find_child("Label").text = str(o+1)
		add_child(new_dot)
			
		#	print(points)

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
