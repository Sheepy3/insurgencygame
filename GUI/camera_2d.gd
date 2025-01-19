extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bounds:int = 1000
	var move_vector:Vector2
	var speed:int = 10
	if Input.is_action_pressed("Move_up"):
		if not position.y < -1*bounds:
			print(position.y)
			move_vector.y=-1
	if Input.is_action_pressed("Move_down"):
		if not position.y > bounds:
			move_vector.y=1
	if Input.is_action_pressed("Move_left"):
		if not position.x < -1*bounds:
			move_vector.x=-1
	if Input.is_action_pressed("Move_right"):
		if not position.x > bounds:
			move_vector.x=1
	position += move_vector*10
	if Input.is_action_just_released("Scroll_up"):
		zoom +=Vector2(0.1,0.1)
		
	if Input.is_action_just_released("Scroll_down"):
		zoom -=Vector2(0.1,0.1)
	if move_vector:
		print(position)
	pass
