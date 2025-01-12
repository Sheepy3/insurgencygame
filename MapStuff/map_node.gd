extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().update_label.connect(_update_label)
	pass # Replace with function body.
	
func _update_label()-> void:
	$Label.text = name
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_a_node_clicked(Name: String) -> void: 
	print(Name)
	
