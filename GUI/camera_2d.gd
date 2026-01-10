extends Camera2D
#@export var zoom_factor:float = 0.1
var zoom_level:int
var camera_speed:int

signal clouds(visibility:bool)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _unhandled_input(event: InputEvent) -> void:
	var dir:int = 0
	if event.is_action_pressed("Scroll_up"):
		dir = 1
		clouds.emit(false)
	if event.is_action_pressed("Scroll_down"):
		if zoom_level == 1:
			clouds.emit(true)
		dir = -1
	zoom_level += dir
	zoom_level = clamp(zoom_level,0,3)
	
func _process(delta: float) -> void:
	var bounds:int = 1000
	var move_vector:Vector2
	if Input.is_action_pressed("Cam_Speed"):
		camera_speed=2000
	else:
		camera_speed=1000
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

	match zoom_level:
		0:
			zoom=lerp(zoom,Vector2(0.25,0.25),0.5)
		1:
			zoom=lerp(zoom,Vector2(0.25,0.25),0.5)
			
		2:
			zoom= lerp(zoom,Vector2(0.5,0.5),0.5)
			
		3: 
			zoom= lerp(zoom,Vector2(1,1),0.5)
