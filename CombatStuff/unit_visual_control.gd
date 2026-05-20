extends Control
@export var Unit_Data:Resource
enum{FIGHTER,INFLUENCE}

func test() ->void:
	print("hi")


func _ready() -> void:
	recolor()

func flip() ->void:
	$F_sprite.flip_h = true
	$I_sprite.flip_h = true


func recolor() -> void:
	$F_sprite.material.set_shader_parameter("tint_color", Unit_Data.color)
	$F_sprite.material.set_shader_parameter("saturation", 0.7)
	if Unit_Data.unit_type == FIGHTER:
		$F_sprite.show()
	else:
		$I_sprite.show()
	if Unit_Data.offcolor:
		$F_sprite.material.set_shader_parameter("value",0.7)
		
	if Unit_Data.disrupted:
		$F_sprite.material.set_shader_parameter("saturation", 0.25)
		position += Vector2(0,20)
		if $F_sprite.flip_h:
			$F_sprite.rotation = 90
			$I_sprite.rotation = 90
		else:
			$F_sprite.rotation = -90
			$I_sprite.rotation = -90
	else:
		position = Vector2(0,0)
		$F_sprite.rotation = 0
		$I_sprite.rotation = 0
