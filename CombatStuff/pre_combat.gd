extends Control

signal initialize_pressed(attacking_fighters:int, attacking_influence:int, target_player_id: int)
signal cancel_pressed

func _ready() -> void:
	pass


func set_counts(fighter_max: int, influence_max:int, players_available:Array) -> void: 
	%Players_dropdown.clear()
	%Fighter_slider.max_value = fighter_max
	%Influence_slider.max_value = influence_max
	#if fighter_max == 0:
		#%Fighter_label_and_count.hide()
		#%Fighter_slider.hide()
	#else:
		#%Fighter_label_and_count.show()
		#%Fighter_slider.show()
	#if influence_max == 0:
		#%Influence_label_and_count.hide()
		#%Influence_slider.hide()
	#else:
		#%Influence_label_and_count.show()
		#%Influence_slider.show()
	for player:int in players_available:
		var player_resource:Resource = Overseer.Identify_player(player)
		var player_color:Vector3 = player_resource.color
		var color_string:String = Overseer.get_player_color_name(player_color)
		var final_string:String = str(player_resource.Player_ID) + " [" + color_string + "]"
		%Players_dropdown.add_item(final_string,player)
		
func kill() -> void:
	queue_free()


func _on_initialize_pressed() -> void:
	#I lowkey hotwired this shit to get rid of the sliders with the least amount of effort possible icl
	var selected_index: int = %Players_dropdown.selected
	var target_player_id: int = %Players_dropdown.get_item_id(selected_index)
	initialize_pressed.emit(%Fighter_slider.max_value, %Influence_slider.max_value, target_player_id)
	
func _on_cancel_pressed() -> void:
	cancel_pressed.emit()


func _on_influence_slider_value_changed(value: int) -> void:
	%Influence_count.text = str(value)
	pass # Replace with function body.


func _on_fighter_slider_value_changed(value: int) -> void:
	%Fighter_count.text = str(value)
