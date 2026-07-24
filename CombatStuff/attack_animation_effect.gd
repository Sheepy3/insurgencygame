extends Node2D
@export var Is_binoculars:bool = false
@export var flipped:bool = false

# These rates preserve the original per-frame values at 165 FPS.
const BINOCULAR_SPEED: float = 165.0
const BINOCULAR_ROTATION_SPEED: float = 99.0

func _ready() -> void:
	if Is_binoculars:
		$Attack_Binoculars.show()
	else:
		$Attack_MuzzleFlash.show()
	if flipped:
		$Attack_MuzzleFlash.flip_h = true
		
func _process(delta: float) -> void:
	if Is_binoculars:
		if flipped:
			position -= Vector2(BINOCULAR_SPEED * delta, 0.0)
			rotation_degrees += BINOCULAR_ROTATION_SPEED * delta
		else:
			position += Vector2(BINOCULAR_SPEED * delta, 0.0)
			rotation_degrees -= BINOCULAR_ROTATION_SPEED * delta
		
func _on_timer_timeout() -> void:
	queue_free()
