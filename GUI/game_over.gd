extends Control

@onready var viewport_container:SubViewportContainer = %SubViewportContainer
@onready var fade_material:ShaderMaterial = viewport_container.material

func _ready() -> void:
	pass

func Populate_title(winners:Array) -> void:
	pass

func Populate_stats(stats:Dictionary) -> void:
	for vboxes:VBoxContainer in %Player_stats_Container.get_children():
		for stat_displays:Label in vboxes.get_children():
			for keys:String in stats.keys():
				if stat_displays.name.contains(keys):
					stat_displays.text += " "+str(stats[keys])
					break

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

func _on_show_map_button_pressed() -> void:
	pixel_fade_out()
