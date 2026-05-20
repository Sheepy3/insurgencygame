extends Control


func _ready() -> void:
	pass

func set_counts(weapons_max: int, money_max:int, manpower_max:int) -> void:
	%Weapons_slider.max_value = weapons_max
	%Money_slider.max_value = money_max
	%Manpower_slider.max_value = manpower_max
	
	if weapons_max == 0:
		%Weapons_label_and_count.hide()
		%Weapons_slider.hide()
	else:
		%Weapons_label_and_count.show()
		%Weapons_slider.show()
	if money_max == 0:
		%Money_label_and_count.hide()
		%Money_slider.hide()
	else:
		%Money_label_and_count.show()
		%Money_slider.show()
	if manpower_max == 0:
		%Manpower_label_and_count.hide()
		%Manpower_slider.hide()
	else:
		%Manpower_label_and_count.show()
		%Manpower_slider.show()



func _on_weapons_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_money_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_manpower_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_ready_button_pressed() -> void:
	if %Ready_Button.text == "Ready":
		%Ready_Button.text = "Not Ready"
	else:
		%Ready_Button.text = "Ready"
