extends Control
var unit_scene:PackedScene = load("res://CombatStuff/unit_visual_control.tscn")
var effect_scene:PackedScene = load("res://CombatStuff/Attack_Animation_Effect.tscn")
enum player_type {COMBATANT,SPECTATOR} 
enum visual_type {BINOCULARS,FLASH} 
enum visual_direction {LEFT,RIGHT}
enum RESOURCE_TYPE {NONE, WEAPONS, MONEY, MANPOWER} 
signal combat_over
var my_id:int
var current_type:int = player_type.COMBATANT
var left_side_player_id: int = -1
var right_side_player_id: int = -1
var _unit_position_update_queued: bool = false
@onready var viewport_container := %SubViewportContainer
@onready var fade_material: ShaderMaterial = viewport_container.material

func _ready() -> void:
	my_id = multiplayer.get_unique_id()
	get_viewport().size_changed.connect(_queue_unit_position_update)
	_queue_unit_position_update()
	Overseer.toggle_ready.connect(_toggle_ready)
	Overseer.update_combat.connect(_finalize_combat)
	%Ready_Button.disabled = true
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
	#TODO: FIX
	# Attacker toggled, defender should see opponent status
	if player == 0 and Overseer.defending_player == my_id:
		%Opponent_ready_label.text = "Your opponent is ready" if Overseer.attacker_ready else "Your opponent is not ready"

	# Defender toggled, attacker should see opponent status
	elif player == 1 and Overseer.attacking_player == my_id:
		%Opponent_ready_label.text = "Your opponent is ready" if Overseer.defender_ready else "Your opponent is not ready"

func swap_header(side_swap:bool) -> void: #pass bool and handle logic in game_ui, because side ID and my ID are always consistent when this runs...
	print("left side ID:"+str(left_side_player_id))
	print("right side ID:"+str(right_side_player_id))
	print("my_id:"+str(multiplayer.get_unique_id()))
	print("-----")
	if side_swap:
		%Attacker_bet.horizontal_alignment = 2
		%Defender_bet.horizontal_alignment = 0
		%HeaderContainer.move_child(%Attacker_bet,-1)
		%HeaderContainer.move_child(%Defender_bet,0)
	else:
		%Attacker_bet.horizontal_alignment = 0
		%Defender_bet.horizontal_alignment = 2
		%HeaderContainer.move_child(%Attacker_bet,0)
		%HeaderContainer.move_child(%Defender_bet,-1)

func _queue_unit_position_update() -> void:
	if _unit_position_update_queued:
		return
	_unit_position_update_queued = true
	call_deferred("_apply_unit_spawn_positions")

func _apply_unit_spawn_positions() -> void:
	_unit_position_update_queued = false
	await get_tree().process_frame
	%Unit_spawn.position = %PanelContainer.position + Vector2(290, 65)

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
		%Unit_spawn.add_child(unit_visual)
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
		%Unit_spawn.add_child(unit_visual)
		unit_visual.position.x += offsetX
		unit_visual.position.y += offsetY
		offsetY+=spacing
		offsetX = (0.25*offsetY) + opposition_offset 
		i+=1
		
func set_counts(weapons_max: int, money_max:int, manpower_max:int) -> void:
	%Weapons_slider.max_value = weapons_max
	%Money_slider.max_value = money_max
	%Manpower_slider.max_value = manpower_max
	%Weapons_slider.value = 0
	%Money_slider.value = 0
	%Manpower_slider.value = 0
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
	if value > 0:
		%Money_slider.editable = false
		%Manpower_slider.editable = false
		%Ready_Button.disabled = false
	else:
		%Money_slider.editable = true
		%Manpower_slider.editable = true
		%Ready_Button.disabled = true

func _on_money_slider_value_changed(value: int) -> void:
	%Money_count.text = str(value)
	if value > 0:
		%Weapons_slider.editable = false
		%Manpower_slider.editable = false
		%Ready_Button.disabled = false
	else:
		%Weapons_slider.editable = true
		%Manpower_slider.editable = true
		%Ready_Button.disabled = true


func _on_manpower_slider_value_changed(value: int) -> void:
	%Manpower_count.text = str(value)
	if value > 0:
		%Money_slider.editable = false
		%Weapons_slider.editable = false
		%Ready_Button.disabled = false
	else:
		%Money_slider.editable = true
		%Weapons_slider.editable = true
		%Ready_Button.disabled = true

func _on_ready_button_pressed() -> void:
	Overseer.request_update_toggle.rpc(%Weapons_slider.value,%Money_slider.value,%Manpower_slider.value)
	if %Ready_Button.text == "Ready": ###TODO: FIX WEIRD SYNCING ISSUE
		%Ready_Button.text = "Not Ready"
		%Money_slider.editable = true
		%Weapons_slider.editable = true
		%Manpower_slider.editable = true
	else:
		%Ready_Button.text = "Ready"
		%Money_slider.editable = false
		%Weapons_slider.editable = false
		%Manpower_slider.editable = false

#var combat_data:Array = [map_node_path,attacking_resource_type,attacking_resource_allocation,defending_resource_type,defending_resource_allocation,final_damage,winning_player]
func _reset_combat_actual() -> void:
	for child: Node in %Unit_spawn.get_children():
		child.queue_free()
	%Attacker_bet.text = "Attacker: ???"
	%Attacker_arrow.text = ""
	%Winner_damage.text = "Winner: ??? Damage"
	%Defender_arrow.text = ""
	%Defender_bet.text = "Defender: ???"
	%Money_slider.editable = true
	%Weapons_slider.editable = true
	%Manpower_slider.editable = true
	%Opponent_ready_label.text = "Your opponent is not ready"
	%Ready_Button.disabled = true
	
func _finalize_combat(combat_data:Array) -> void:

	var attacker_res_type_string:String
	var defender_res_type_string:String
	
	match combat_data[1]:
		RESOURCE_TYPE.WEAPONS:
			attacker_res_type_string = " Weapons"
		RESOURCE_TYPE.MONEY:
			attacker_res_type_string = " Money"
		RESOURCE_TYPE.MANPOWER:
			attacker_res_type_string = " Manpower"
	match combat_data[3]:
		RESOURCE_TYPE.WEAPONS:
			defender_res_type_string = " Weapons"
		RESOURCE_TYPE.MONEY:
			defender_res_type_string = " Money"
		RESOURCE_TYPE.MANPOWER:
			defender_res_type_string = " Manpower"
	%Attacker_bet.text = "Attacker: " + str(combat_data[2]) + attacker_res_type_string
	%Defender_bet.text = "Defender: " + str(combat_data[4]) + defender_res_type_string
	%Attacker_arrow.text = ""
	%Defender_arrow.text = ""

	var winning_player_id: int = combat_data[6]

	if winning_player_id == left_side_player_id:
		%Attacker_arrow.text = "<-"
	elif winning_player_id == right_side_player_id:
		%Defender_arrow.text = "->"
	elif winning_player_id == 0:
		pass
	else:
		push_warning("Winner was neither left nor right side: " + str(winning_player_id))
		
		
	if winning_player_id == 0:
		%Winner_damage.text = "Tie: 0 Damage"
	else:
		%Winner_damage.text = "Winner: " + str(combat_data[5]) + " Damage"


	var Map_node: Node = get_node(combat_data[0])
	Map_node.reorder_units()

	for child: Node in %Unit_spawn.get_children():
		child.queue_free()
		
	var left_units: Array = []
	var right_units: Array = []

	for unit: Resource in Map_node.unit_list:
		if unit.player_ID == left_side_player_id:
			left_units.append(unit)
		elif unit.player_ID == right_side_player_id:
			right_units.append(unit)
		#else:
			#print("finalize ignored unit owner: ", unit.player_ID)
	#
	#print("final left units: ", left_units.size())
	#print("final right units: ", right_units.size())

	display_allies(left_units)
	display_opposition(right_units)
	spawn_attack_effects()
	%Timer.start()

func spawn_attack_effects() -> void:
	for child:Node in %Unit_spawn.get_children():
		if child.Unit_Data.disrupted == true:
			continue
		var instanced_effect_scene:Node = effect_scene.instantiate()
		if child.Unit_Data.unit_type == 1:
			if child.flipped:
				instanced_effect_scene.position -= Vector2(0,0)
				instanced_effect_scene.flipped = true
			else:
				instanced_effect_scene.position += Vector2(55,0)
			instanced_effect_scene.Is_binoculars = true
			AudioController.play_sfx(AudioController.Sfx.THROW)
		if child.Unit_Data.unit_type == 0:
			if child.flipped:
				instanced_effect_scene.position -= Vector2(18,13)
				instanced_effect_scene.flipped = true
			else:
				instanced_effect_scene.position += Vector2(55,-11)
			AudioController.play_sfx(AudioController.Sfx.GUN_FIRE)
		child.add_child(instanced_effect_scene)

func _on_timer_timeout() -> void:
	_reset_combat_actual()
	combat_over.emit()

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
