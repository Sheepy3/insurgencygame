extends Camera2D
#@export var zoom_factor:float = 0.1
var zoom_level:int
var camera_speed:int
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bounds:int = 1000
	var move_vector:Vector2
	if Input.is_action_pressed("Cam_Speed"):
		camera_speed=1600
	else:
		camera_speed=800
	#var speed:int = 10
	if Input.is_action_pressed("Move_up"):
		if not position.y < -1*bounds:
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
	position += move_vector*camera_speed*delta
	var dir:int = 0
	if Input.is_action_just_pressed("Scroll_up"):
		dir = 1
	if Input.is_action_just_pressed("Scroll_down"):
		dir = -1
	zoom_level += dir
	zoom_level = clamp(zoom_level,0,2)
	match zoom_level:
		0:
			zoom=lerp(zoom,Vector2(0.25,0.25),0.5)
		1:
			zoom= lerp(zoom,Vector2(0.5,0.5),0.5)
		2: 
			zoom= lerp(zoom,Vector2(1,1),0.5)
