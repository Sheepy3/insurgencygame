extends Area2D
signal A_node_clicked(Name: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_pickable(true)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Detects when Node is clicked on by mouse
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("Mouse_left_click"): 
		print("you have clicked on node " + str($"../Label".text)) #Prints the name of the node that is clicked on
		A_node_clicked.emit(get_parent().name)
