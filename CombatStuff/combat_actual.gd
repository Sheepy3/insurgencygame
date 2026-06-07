extends Control
var unit_scene:PackedScene = load("res://CombatStuff/unit_visual_control.tscn")
enum player_type {COMBATANT,SPECTATOR} 
var current_type:int = player_type.COMBATANT
func _ready() -> void:
	get_viewport().size_changed.connect(_on_window_resized)
	_on_window_resized()
	Overseer.toggle_ready.connect(_toggle_ready)
	#set_counts(5,5,5)
	#switch_player_type(player_type.SPECTATOR)
	#var player1_units: Array[Unit] = []
	#var player2_units: Array[Unit] = []
	#for i in range(5):
		#var unit1 := Unit.new()
		#unit1.unit_type = 0 # Fighter
		#unit1.unit_UUID = str(Time.get_unix_time_from_system()) + "_p1_" + str(i)
		#unit1.disrupted = false
		#unit1.player_ID = 1
		#unit1.color = Vector3(1,0,0)
		#unit1.offcolor = false
		#player1_units.append(unit1)
#
		#var unit2 := Unit.new()
		#unit2.unit_type = 0 # Fighter
		#unit2.unit_UUID = str(Time.get_unix_time_from_system()) + "_p2_" + str(i)
		#unit2.disrupted = false
		#unit2.player_ID = 2
		#unit2.color = Vector3(0,0,1)
		#unit2.offcolor = false
		#player2_units.append(unit2)
	#
	#display_allies(player1_units)
	#display_opposition(player2_units)

func _toggle_ready(player: int) -> void:
	print("toggling!")

	var my_id := multiplayer.get_unique_id()

	# Attacker toggled; defender should see opponent status
	if player == 0 and Overseer.defending_player == my_id:
		%Opponent_ready_label.text = "Your opponent is ready" if Overseer.attacker_ready else "Your opponent is not ready"

	# Defender toggled; attacker should see opponent status
	elif player == 1 and Overseer.attacking_player == my_id:
		%Opponent_ready_label.text = "Your opponent is ready" if Overseer.defender_ready else "Your opponent is not ready"

func _on_window_resized() -> void:
	%Unit_spawn_1.position = %PanelContainer.position + Vector2(290,65)
	%Unit_spawn_2.position = %PanelContainer.position + Vector2(170,125)
	print("hi")
	pass

func display_allies(allies:Array) -> void:
	var opposition_offset:int = 0
	if current_type == player_type.SPECTATOR:
		opposition_offset = 100
	var offsetX:int = opposition_offset
	var offsetY:int = 0
	var count:int = allies.size()
	var spacing:int
	if count > 0:
		spacing = 200/count
	var i:int = 0
	for ally:Resource in allies:
		var unit_visual := unit_scene.instantiate() #GENERATE VISUAL
		unit_visual.Unit_Data = ally
		print(ally)
		if (i % 2 != 0) && count > 2:
			pass
			unit_visual.Unit_Data.offcolor = true
		%Unit_spawn_1.add_child(unit_visual)
		unit_visual.position.x -= offsetX
		unit_visual.position.y += offsetY
		offsetY+=spacing
		offsetX = 0.25*offsetY + opposition_offset
		i+=1
		
		
		
func display_opposition(opps:Array) -> void:
	var opposition_offset:int
	if current_type == player_type.COMBATANT:
		opposition_offset = 250
	if current_type == player_type.SPECTATOR:
		opposition_offset = 125
	var offsetX:int = opposition_offset
	var offsetY:int = 0
	var count:int = opps.size()
	var spacing:int
	if count > 0:
		spacing = 200/count
	var i:int = 0
	for opp:Resource in opps:
		var unit_visual := unit_scene.instantiate() #GENERATE VISUAL
		unit_visual.Unit_Data = opp
		unit_visual.flip()
		if (i % 2 != 0) && count > 2:
			pass
			unit_visual.Unit_Data.offcolor = true
		%Unit_spawn_1.add_child(unit_visual)
		unit_visual.position.x += offsetX
		unit_visual.position.y += offsetY
		offsetY+=spacing
		offsetX = (0.25*offsetY) + opposition_offset 
		i+=1
		
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

func set_opposition_counts(weapons_max: int, money_max:int, manpower_max:int) -> void:
	%Opposition_Weapons_count.text = str(weapons_max)
	%Opposition_Money_count.text = str(money_max)
	%Opposition_Manpower_count.text = str(manpower_max)


func switch_player_type(type: int) -> void:
	
	if type == player_type.COMBATANT:
		%Config_Sidebar.show()
	elif type == player_type.SPECTATOR:
		%Config_Sidebar.hide()
	current_type = type

func _on_weapons_slider_value_changed(value: int) -> void:
	%Weapons_count.text = str(value)

func _on_money_slider_value_changed(value: int) -> void:
	%Money_count.text = str(value)

func _on_manpower_slider_value_changed(value: int) -> void:
	%Manpower_count.text = str(value)

func _on_ready_button_pressed() -> void:
	Overseer.request_update_toggle.rpc()
	if %Ready_Button.text == "Ready":
		%Ready_Button.text = "Not Ready"
		%Money_slider.editable = true
		%Weapons_slider.editable = true
		%Manpower_slider.editable = true
	else:
		%Ready_Button.text = "Ready"
		%Money_slider.editable = false
		%Weapons_slider.editable = false
		%Manpower_slider.editable = false
