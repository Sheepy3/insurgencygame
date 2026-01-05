extends AnimationPlayer
#@export var anim_speed:int
func _ready() -> void:
	play("default")
#	speed_scale = anim_speed
	set_section(0.03,0.99)
