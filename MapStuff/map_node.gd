extends Node2D
signal A_node_clicked(Name: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Map_Node_Area2D.set_pickable(true) #sets-up the clickable area for the map nodes
	if get_parent().name != "root":
		get_parent().update_label.connect(_update_label)
	
	pass # Replace with function body.
	
func _update_label()-> void:
	$Label.text = name
	pass

# Detects when Node is clicked on by mouse
func _on_map_node_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("Mouse_left_click"): 
		print("you have clicked on node " + str($Label.text)) #Prints the name of the node that is clicked on
		A_node_clicked.emit(name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
