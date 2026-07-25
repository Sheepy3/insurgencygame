extends CanvasLayer

@onready var game_config:Node = get_tree().current_scene.find_child("GameConfig")
@onready var main_menu:Node = get_tree().current_scene.find_child("MainMenuLayer")

signal settings_return_to_lobby
signal settings_leave_game

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

func _on_back_to_lobby_button_pressed() -> void:
	if game_config.In_server and !main_menu.visible:
		AudioController.stop_music()
		settings_return_to_lobby.emit()
		hide()

func _on_leave_game_button_pressed() -> void:
	if game_config.In_server:
		AudioController.stop_music()
		settings_leave_game.emit()
		hide()
