extends Node2D
@export var Is_binoculars:bool = false
@export var flipped:bool = false
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
			position -= Vector2(1,0)
			rotation_degrees +=0.6
		else:
			position +=Vector2(1,0)
			rotation_degrees -=0.6
		
func _on_timer_timeout() -> void:
	queue_free()
