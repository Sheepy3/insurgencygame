extends Control
var unit_scene:PackedScene = load("res://CombatStuff/unit_visual_control.tscn")

func _ready() -> void:
	get_viewport().size_changed.connect(_on_window_resized)
	_on_window_resized()
	set_counts(5,5,5)
	var player1_units: Array[Unit] = []
	var player2_units: Array[Unit] = []

	for i in range(5):
		var unit1 := Unit.new()
		unit1.unit_type = 0 # Fighter
		unit1.unit_UUID = str(Time.get_unix_time_from_system()) + "_p1_" + str(i)
		unit1.disrupted = false
		unit1.player_ID = 1
		unit1.color = Vector3(1,0,0)
		unit1.offcolor = false
		player1_units.append(unit1)

		var unit2 := Unit.new()
		unit2.unit_type = 0 # Fighter
		unit2.unit_UUID = str(Time.get_unix_time_from_system()) + "_p2_" + str(i)
		unit2.disrupted = true
		unit2.player_ID = 2
		unit2.color = Vector3(0,0,1)
		unit2.offcolor = false
		player2_units.append(unit2)
	
	_display_allies(player1_units)
	_display_opposition(player2_units)


func _on_window_resized() -> void:
	%Unit_spawn_1.position = %PanelContainer.position + Vector2(220,40)
	%Unit_spawn_2.position = %PanelContainer.position + Vector2(100,100)
	print("hi")
	pass

func _display_allies(allies:Array) -> void:
	var offsetX:int = 0
	var offsetY:int = 0
	var count:int = allies.size()
	var spacing:int = 200/count
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
		offsetX = 0.25*offsetY 
		i+=1
		
		
		
func _display_opposition(opps:Array) -> void:
	var opposition_offset:int = 250
	var offsetX:int = opposition_offset
	var offsetY:int = 0
	var count:int = opps.size()
	var spacing:int = 200/count
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



func _on_weapons_slider_value_changed(value: int) -> void:
	%Weapons_count.text = str(value)

func _on_money_slider_value_changed(value: int) -> void:
	%Money_count.text = str(value)

func _on_manpower_slider_value_changed(value: int) -> void:
	%Manpower_count.text = str(value)

func _on_ready_button_pressed() -> void:
	if %Ready_Button.text == "Ready":
		%Ready_Button.text = "Not Ready"
	else:
		%Ready_Button.text = "Ready"
