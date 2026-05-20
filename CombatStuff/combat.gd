extends Control

signal initialize_pressed
signal cancel_pressed

func _ready() -> void:
	pass


func set_counts(fighter_max: int, influence_max:int) -> void:
	%Fighter_slider.max_value = fighter_max
	%Influence_slider.max_value = influence_max
	if fighter_max == 0:
		%Fighter_label_and_count.hide()
		%Fighter_slider.hide()
	else:
		%Fighter_label_and_count.show()
		%Fighter_slider.show()
	if influence_max == 0:
		%Influence_label_and_count.hide()
		%Influence_slider.hide()
	else:
		%Influence_label_and_count.show()
		%Influence_slider.show()


func kill() -> void:
	queue_free()


func _on_initialize_pressed() -> void:
	initialize_pressed.emit()

func _on_cancel_pressed() -> void:
	cancel_pressed.emit()


func _on_influence_slider_value_changed(value: int) -> void:
	%Influence_count.text = str(value)
	pass # Replace with function body.


func _on_fighter_slider_value_changed(value: int) -> void:
	%Fighter_count.text = str(value)
