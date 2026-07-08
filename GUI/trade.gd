extends Control

signal trade
signal cancel_trade

func _ready() -> void:
	pass


func set_counts(weapons: int, money:int, manpower:int) -> void: 
	%Players_dropdown.clear()
	%Weapons_slider.max_value = weapons
	%Money_slider.max_value = money
	%Manpower_slider.max_value = manpower
	%Weapons_slider.value = 0
	%Money_slider.value = 0
	%Manpower_slider.value = 0
	%Weapons_count.text = "0"
	%Money_count.text = "0"
	%Manpower_count.text = "0"
	for player:Player in Overseer.player_list:
		var player_color:Vector3 = player.color
		var color_string:String = Overseer.get_player_color_name(player_color)
		var final_string:String = str(player.Player_ID) + " [" + color_string + "]"
		%Players_dropdown.add_item(final_string,player.Player_ID)

func _on_initialize_pressed() -> void:
	var selected_index: int = %Players_dropdown.selected
	if selected_index < 0:
		return
	var target_player_id: int = %Players_dropdown.get_item_id(selected_index)
	
	Overseer.attempt_complete_trade.rpc(target_player_id,int(%Weapons_slider.value),int(%Money_slider.value),int(%Manpower_slider.value))
	hide()

func _on_weapons_slider_value_changed(value: float) -> void:
	%Weapons_count.text = str(int(value))

func _on_money_slider_value_changed(value: float) -> void:
	%Money_count.text = str(int(value))

func _on_manpower_slider_value_changed(value: float) -> void:
	%Manpower_count.text = str(int(value))

func _on_cancel_pressed() -> void:
	cancel_trade.emit()
	hide()
