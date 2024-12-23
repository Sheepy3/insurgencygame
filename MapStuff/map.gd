extends Node2D
signal update_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var num = 1
	for child in get_children():
		if child is not Camera2D:
			child.name = str(num)
			num+=1
	update_label.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
