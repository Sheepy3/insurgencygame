extends CanvasLayer
signal The_action(action: String)
var Store_action: String = ""
var last_clicked_node:String = ""
var Unique_player_ID:int 
var UI_Unit_Scene: PackedScene = preload("res://GUI/UI_Unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Open_Market_Button.set_disabled(true)
	$Error_Message.hide()
	#Overseer.change_player.connect(_player_switch_ui)
	Overseer.change_phase.connect(_phase_switch_ui)
	Overseer.game_started.connect(connect_update_UI)
	get_parent().find_child("Camera2D").clouds.connect(_toggle_clouds)
	#Overseer.cycle_players()
	_phase_switch_ui()
	%Support_store_window.hide()
	for boxes:HBoxContainer in $Action_Container/VBoxContainer.get_children(true):
		for UI_elements:Control in boxes.get_children(true):
			if UI_elements is Button:
				#if UI_elements.name.ends_with("Place_Button"):
				UI_elements.pressed.connect(Check_container_action.bind(UI_elements.name))

func _on_player_switch_button_pressed() -> void:
	pass
	#Overseer.cycle_players()

func Check_container_action(Button_name:String) -> void:
	match Button_name:
		"Base_Buy_Button":
			check_buy_action.rpc("Buy_Base",Unique_player_ID)
		
		"Base_Place_Button":
			The_action.emit("Base_placing")
			find_child("Dynamic_Action").text = "Base placing" #Updates "Dynamic" UI with current action (building a base)
		
		"Fighter_Buy_Button":
			check_buy_action.rpc("Buy_Fighter",Unique_player_ID)
		
		"Fighter_Place_Button":
			The_action.emit("Fighter_placing")
			find_child("Dynamic_Action").text = "Fighter placing" #Updates "Dynamic" UI with current action (placing Figher)
		
		"Influence_Buy_Button":
			check_buy_action.rpc("Buy_Influence",Unique_player_ID)
		
		"Influence_Place_Button":
			The_action.emit("Influence_placing")
			find_child("Dynamic_Action").text = "Influence placing" #Updates "Dynamic" UI with current action (placing Influence)
		
		"Intelligence_Network_Buy_Button":
			check_buy_action.rpc("Buy_Intel",Unique_player_ID)
		
		"Intelligence_Network_Place_Button":
			The_action.emit("Intel_placing")
			find_child("Dynamic_Action").text = "Intelligence Network placing" #Updates "Dynamic" UI with current action (placing Intelligence Network)
		
		"Logistics_Network_Buy_Button":
			check_buy_action.rpc("Buy_Logs",Unique_player_ID)
		
		"Logistics_Network_Place_Button":
			The_action.emit("Logs_placing")
			find_child("Dynamic_Action").text = "Logistics Network placing" #Updates "Dynamic" UI with current action (placing Logistics Network)

func _player_switch_ui() -> void:
	$PanelContainer2/VBoxContainer/HSplitContainer/Dynamic_Player.text = Overseer.current_player
	#update_Player_Info()

func _phase_switch_ui() -> void:
	match Overseer.current_phase:
		0:
			$Current_Phase.text = "Maintenence"
		1:
			$Current_Phase.text = "Purchase Units & Infrastructure"
		2:
			$Current_Phase.text = "Place Military Units & Infrastructure"
		3:
			$Current_Phase.text = "Move Units"
		4:
			$Current_Phase.text = "Collect Resources"
			Overseer.Phase_cycle += 1

func _on_phase_button_pressed() -> void:
	Overseer.cycle_phases()

@rpc("authority","call_local")
func action_error(error_message:String, player_ID:int) -> void:
	if multiplayer.get_unique_id() == player_ID: 
		$Error_Message.text = error_message
		$Error_Message.show()
		$Error_timer.start()

func _on_error_timer_timeout() -> void:
	$Error_Message.hide()

func _on_open_market_button_pressed() -> void:
	$Open_Market_Button.hide()
	%Support_store_window.show()
	#!!! Reminder !!! The portion below is added for testing purposes
	# Should be depricated when testing is finished
	if multiplayer.is_server():
		for players:Resource in Overseer.player_list:
			players.Weapons += 30
			players.Money += 30
			players.Man_power += 30
		Overseer.Resources_to_rpc.rpc()

func _on_buy_button_pressed() -> void:
	Store_action = "Buy"

func _on_sell_button_pressed() -> void:
	Store_action = "Sell"

func _on_manpower_button_pressed() -> void:
	Manpower_action.rpc(Unique_player_ID,Store_action)

func _on_weapons_button_pressed() -> void:
	Weapons_action.rpc(Unique_player_ID,Store_action)

func update_Player_Info() -> void:
	var player:Resource = Overseer.Identify_player(Unique_player_ID)
	$Player_Info/HBoxContainer/Guns.text = str(player.Weapons)
	$Player_Info/HBoxContainer/Money.text = str(player.Money)
	$Player_Info/HBoxContainer/Population.text = str(player.Man_power)
	$Player_Info/HBoxContainer/VictoryPoints.text = str(player.Victory_points)
	$Player_Info/HBoxContainer/Spacer2/Base_count.text = str(player.Player_storage["Military_Base"])
	$Player_Info/HBoxContainer/Spacer2/Fighter_count.text = str(player.Player_storage["Fighter"])
	$Player_Info/HBoxContainer/Spacer2/Influence_count.text = str(player.Player_storage["Influence"])
	$Player_Info/HBoxContainer/Spacer2/Intelligence_count.text = str(player.Player_storage["Intelligence"])
	$Player_Info/HBoxContainer/Spacer2/Logistics_count.text = str(player.Player_storage["Logistics"])

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	%Support_store_window.position = Vector2(975,36)

func _on_support_store_window_close_requested() -> void:
	%Support_store_window.hide()
	$Open_Market_Button.show()

func _on_support_store_window_window_input(event: InputEvent) -> void:
	$Store_bounds.global_position = %Support_store_window.position 

func _toggle_clouds(visibility:bool) -> void:
	if visibility == true:
		#%Clouds.show()
		cloud_fade_in_target = 0.1
	else:
		#%Clouds.hide()
		cloud_fade_in_target = 0
	pass
var cloud_fade_in:float
var cloud_fade_in_target:float

func _process(delta: float) -> void:
	cloud_fade_in = lerp(cloud_fade_in,cloud_fade_in_target,0.1)
	%Clouds.material.set_shader_parameter("opacity",cloud_fade_in)


@rpc("any_peer","call_local")
func Manpower_action(Player_ID:int,action:String)-> void:
	if multiplayer.is_server():
		Store_action = action
		var Player_resource:Resource = Overseer.Identify_player(Player_ID)
		if Store_action == "Buy" and Player_resource.Money >= 5:
			Player_resource.Man_power += 1
			Player_resource.Money -= 5
			Store_action = ""
			Overseer.Resources_to_rpc()
		elif Store_action == "Sell" and Player_resource.Man_power >= 1:
			Player_resource.Man_power -= 1
			Player_resource.Money += 5
			Store_action = ""
			Overseer.Resources_to_rpc()
		else: 
			action_error.rpc("You do not have enough resources to complete this transaction!",Player_ID)

@rpc("any_peer","call_local")
func Weapons_action(Player_ID:int,action:String)-> void:
	if multiplayer.is_server():
		Store_action = action
		var Player_resource:Resource = Overseer.Identify_player(Player_ID)
		if Store_action == "Buy" and Player_resource.Money >= 3:
			Player_resource.Weapons += 1
			Player_resource.Money -= 3
			Store_action = ""
			Overseer.Resources_to_rpc()
		elif Store_action == "Sell" and Player_resource.Weapons >= 1:
			Player_resource.Weapons -= 1
			Player_resource.Money += 3
			Store_action = ""
			Overseer.Resources_to_rpc()
		else:
			action_error.rpc("You do not have enough resources to complete this transaction!",Player_ID)

func connect_update_UI() -> void:
	Overseer.player_resources_updated.connect(update_Player_Info)
	Overseer.player_resources_updated.connect(Check_store_unlocked)
	Unique_player_ID = multiplayer.get_unique_id()

func update_node_unit_list(units:Array, mapnode:StringName) -> void:
	last_clicked_node = mapnode
	reset_node_unit_list()
	for unit:Resource in units:
		if unit.player_ID == multiplayer.get_unique_id():
			var new_unit_display:Control = UI_Unit_Scene.instantiate()
			new_unit_display.unit_resource = unit
			new_unit_display.source_node = str(mapnode)
			new_unit_display.move_unit.connect(move_unit_function)
			#new_unit_display.set_color(unit.color)
			#new_unit_display.set_type(unit.unit_type)
			%Unit_Display.add_child(new_unit_display)

func move_unit_function(unit_resource:Resource, source_node:String) -> void:
	print("move unit from " + source_node)
	var packed_number:String = "%05d" % int(source_node)
	if unit_resource.unit_type == 0:
		var packed_string:String = "move_fighter_"+packed_number
		The_action.emit(packed_string)
	else:
		var packed_string:String = "move_influence_"+packed_number
		The_action.emit(packed_string)

func reset_node_unit_list() -> void:
	for children:Node in %Unit_Display.get_children():
		children.queue_free()

func Check_store_unlocked() -> void:
	var Meets_condition:int
	for corners:String in Overseer.The_support_nodes:
		var checked_node:Node2D = get_parent().find_child(corners)
		for unit:Resource in checked_node.unit_list:
			if unit.player_ID == Unique_player_ID && unit.unit_type == 1:
				Meets_condition +=1
		if checked_node.Has_building && checked_node.building.player_ID == Unique_player_ID:
			Meets_condition += 1
	if Meets_condition >= 1:
		$Open_Market_Button.set_disabled(false)
	else:
		$Open_Market_Button.set_disabled(true)

@rpc("any_peer","call_local")
func check_buy_action(Buyable:String,Player_ID:int) -> void:
	if multiplayer.is_server():
		var Current_player:Resource = Overseer.Identify_player(Player_ID)
		match Buyable:
			"Buy_Base":
				if Current_player.Man_power >= 10 && Current_player.Money >= 30:
					Current_player.Man_power -= 10 
					Current_player.Money -= 30
					Current_player.Player_storage["Military_Base"] += 1
					Overseer.Resources_to_rpc()
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
			"Buy_Fighter":
				if Current_player.Man_power >= 5 && Current_player.Money >= 10 && Current_player.Weapons >= 5:
					Current_player.Man_power -= 5 
					Current_player.Money -= 10 
					Current_player.Weapons -= 5
					Current_player.Player_storage["Fighter"] += 1
					Overseer.Resources_to_rpc()
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
			"Buy_Influence":
				if Current_player.Man_power >= 5 && Current_player.Money >= 15:
					Current_player.Man_power -= 5 
					Current_player.Money -= 15
					Current_player.Player_storage["Influence"] += 1
					Overseer.Resources_to_rpc()
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
			"Buy_Intel":
				if Current_player.Man_power >= 1 && Current_player.Money >= 10:
					Current_player.Man_power -= 1 
					Current_player.Money -= 10
					Current_player.Player_storage["Intelligence"] += 1
					Overseer.Resources_to_rpc()
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
			"Buy_Logs":
				if Current_player.Man_power >= 1 && Current_player.Money >= 5:
					Current_player.Man_power -= 1 
					Current_player.Money -= 5
					Current_player.Player_storage["Logistics"] += 1
					Overseer.Resources_to_rpc()
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
		
