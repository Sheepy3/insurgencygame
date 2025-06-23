extends Node2D
@export var Unit_Data:Resource
enum{FIGHTER,INFLUENCE}

func test() ->void:
	print("hi")


func _ready() -> void:
	recolor()

func  recolor() -> void:
	if Unit_Data.unit_type == FIGHTER:
		$F_sprite.show()
		$F_sprite.material.set_shader_parameter("tint_color", Unit_Data.color)
		$F_sprite.material.set_shader_parameter("intensity", 0.2)
		$F_sprite.material.set_shader_parameter("saturation", 2)
	else:
		$I_sprite.show()
		$I_sprite.material.set_shader_parameter("tint_color", Unit_Data.color)
		$I_sprite.material.set_shader_parameter("intensity", 0.2)
		$I_sprite.material.set_shader_parameter("saturation", 2)
	if Unit_Data.offcolor:
		$F_sprite.material.set_shader_parameter("value",0.7)
