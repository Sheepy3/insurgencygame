extends Node2D
@export var connection:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Node_Path_Area2D.set_pickable(true)
	look_at(connection) # point towards connection
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_node_path_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("Mouse_left_click"): 
		print("you have clicked on Path " + name)
		find_parent("Map_parent").find_child("Dynamic_Clicked").text = "Path " + name
