extends CanvasLayer

func _on_music_slider_value_changed(value: float) -> void:
	AudioController.set_music_volume(%Music_Slider.value)
	%Music_Volume_Label.text = "Music volume (" + str(int(%Music_Slider.value*100)) + "%)"

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioController.set_sfx_volume(%SFX_Slider.value)
	%Sfx_Volume_Label.text = "SFX volume (" + str(int(%SFX_Slider.value*100)) + "%)"


func _on_back_to_game_pressed() -> void:
	Overseer.Settings_Shown = false
	hide()
	

func _on_quit_pressed() -> void:
	get_tree().quit()
