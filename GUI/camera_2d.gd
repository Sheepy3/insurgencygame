extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var move_vector:Vector2
	var speed:int = 10
	if Input.is_action_pressed("Move_up"):
		move_vector.y=-1
	if Input.is_action_pressed("Move_down"):
		move_vector.y=1
	if Input.is_action_pressed("Move_left"):
		move_vector.x=-1
	if Input.is_action_pressed("Move_right"):
		move_vector.x=1
	position += move_vector*10
	if Input.is_action_just_released("Scroll_up"):
		zoom +=Vector2(0.1,0.1)
		print("hi")
	if Input.is_action_just_released("Scroll_down"):
		zoom -=Vector2(0.1,0.1)
	if move_vector:
		print(position)
	pass
