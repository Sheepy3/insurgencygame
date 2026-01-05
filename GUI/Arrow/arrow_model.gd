extends Node3D
var passed_light_color:Vector3
func _ready() -> void:
	$AnimationPlayer.play("default")
	$AnimationPlayer.set_section(0.03,0.99)


func update_visual() ->void:
	print(passed_light_color)
	var converted:Color = Color(passed_light_color.x, passed_light_color.y, passed_light_color.z, 1)
	$Light_1.light_color = converted
	$Light_2.light_color = converted
