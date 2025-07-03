extends Node2D
signal update_label
var map_node:PackedScene = preload("res://MapStuff/Map_Node.tscn")

var column:Array = [120,240,480,600] #120, 240, 120, 240, 
var rows:Array = [0,240,480,720,960,1200,1440] #240 each row
var size:int = 1
#size 5
# rows: 2,4,4,4,4,4,2
# steps = 2+n
# step_base = 2
# row quant = 5+2n 
# column quant = 8+4n
# given size, 
# 1) gen column_count
# 2) gen row_count
# 3) row 1 = origin + mirror
# 4) row 2 = row[3], row[4] + mirror
# 5) row 3 = origin, row[5], row[6] 

func _ready() -> void:
	var rows:Array = []
	var columns:Array = []
	var column_quant:int = 6+(4*(size-1))
	var row_quant:int = 5+(2*size)
	var iterator:int
	rows.append(2) #row generation
	iterator = 1
	for val in size:
		#print(iterator)
		rows.append(2+(2*iterator))
		iterator +=1
	for val in row_quant:
		rows.append(4+(2*size))
	iterator = size
	for val in size:
		rows.append(2+(2*iterator))
		iterator -=1
	rows.append(2)
	
	columns.append(2)
	iterator = 1
	for val in size:
		columns.append(4+(2*iterator))
		iterator +=1
		
	var columns_rows:int = (rows.size()-(size*2))
	for row in columns_rows:
		columns.append(column_quant)
	
	print("size: "+str(size))
	print("rows: "+str(rows))
	print("columns: "+str(columns))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
