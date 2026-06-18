extends Node2D
@export var Unit_Data:Resource
enum{FIGHTER,INFLUENCE}

func test() ->void:
	print("hi")


func _ready() -> void:
	recolor()

func  recolor() -> void:
	$F_sprite.material.set_shader_parameter("tint_color", Unit_Data.color)
	$F_sprite.material.set_shader_parameter("saturation", 0.7)
	if Unit_Data.unit_type == FIGHTER:
		$F_sprite.show()
	else:
		$I_sprite.show()
	if Unit_Data.offcolor:
		pass
		$F_sprite.material.set_shader_parameter("value",0.8)

func set_disrupted() -> void:
	print("i have been disrupted")
	%F_sprite.material.set_shader_parameter("saturation", 0.25)
	%I_sprite.material.set_shader_parameter("saturation", 0.25)
	%F_sprite.position += Vector2(0,20)
	%I_sprite.position += Vector2(0,20)
	$F_sprite.rotation = -90
	$I_sprite.rotation = -90
