extends Control

signal stats_closed
signal leave_game(ID:int)

@onready var viewport_container:SubViewportContainer = %SubViewportContainer
@onready var fade_material:ShaderMaterial = viewport_container.material

func _ready() -> void:
	pass

func Populate_title(winners:Array,End_by_intervention:bool = false) -> void:
	if End_by_intervention:
		if winners.size() > 1:
			%Game_over_title.text += " by the intervention players " +Create_winner_string(winners)+ " have emerged victorious!"
		else: 
			%Game_over_title.text += " by the intervention player " +str(winners[0]) + " has emerged victorious!"
	else:
		if winners.size() > 1:
			%Game_over_title.text += " Players "+Create_winner_string(winners)+ " have emerged victorious!"
		else:
			%Game_over_title.text += str(winners[0])+ " has emerged victorious!"

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
	stats_closed.emit()

func Create_winner_string(Winners:Array) -> String:
	var winners_string:String
	if Winners.size() > 2:
		for entries:int in Winners.size(): 
			if entries == Winners.back():
				winners_string += "& "+ str(Winners[entries])
			else:
				winners_string += str(Winners[entries])+", "
		return winners_string
	else:
		winners_string += str(Winners[0])+" & "+str(Winners[1])
		return winners_string


func _on_leave_game_button_pressed() -> void:
	leave_game.emit(multiplayer.get_unique_id())
