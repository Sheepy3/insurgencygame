extends Control

@onready var viewport_container := %SubViewportContainer
@onready var fade_material: ShaderMaterial = viewport_container.material

func _ready() -> void:
	pass

func pixel_fade_in(duration: float = 0.5) -> void:
	show()
	fade_material.set_shader_parameter("progress", 0.0)

	var tween := create_tween()
	tween.tween_method(
		func(v: float) -> void: fade_material.set_shader_parameter("progress", v),
		0.0,
		1.0,
		duration
	)

func pixel_fade_out(duration: float = 0.5) -> void:
	fade_material.set_shader_parameter("progress", 1.0)
	var tween := create_tween()
	tween.tween_method(
		func(v: float) -> void: fade_material.set_shader_parameter("progress", v),
		1.0,
		0.0,
		duration
	)
	await tween.finished
	hide()
