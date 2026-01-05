extends Node2D
var light_color:Vector3

func _ready() -> void:
	$SubViewport/arrow.passed_light_color = light_color
	$SubViewport/arrow.update_visual()

	
func _on_timer_timeout() -> void:
	queue_free()
	
