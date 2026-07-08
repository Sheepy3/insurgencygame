extends CanvasLayer
signal The_action(action: String)
var Store_action: String = ""
var last_clicked_node:String = ""
var Unique_player_ID:int 
var UI_Unit_Scene: PackedScene = preload("res://GUI/UI_Unit.tscn")
var UI_pre_combat_Scene: PackedScene = preload("res://CombatStuff/pre_combat.tscn")
var hidden_ui_nodes: Array[CanvasItem] = []
var Preview_placables:Array = [
	preload("res://Assets/Icons/gun.png"),
	preload("res://Assets/Military/Tent.png"),
	preload("res://Assets/Military/soldier.png"),
	preload("res://Assets/Military/binoculars.png"),
	preload("res://Assets/Icons/IntelNetwork.png"),
	preload("res://Assets/Icons/LogiNetwork.png")
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Open_Market_Button.set_disabled(true)
	$Error_Message.hide()
	#Overseer.change_player.connect(_player_switch_ui)
	Overseer.change_phase.connect(_phase_switch_ui)
	#Overseer.change_phase.connect()
	Overseer.game_started.connect(connect_update_UI)
	%Combat.combat_over.connect(_return_ui_after_combat)
	$Pre_Combat.initialize_pressed.connect(_on_precombat_initialize)
	$Pre_Combat.cancel_pressed.connect(_on_precombat_cancel)
	get_parent().find_child("Camera2D").clouds.connect(_toggle_clouds)
	#Overseer.cycle_players()
	_phase_switch_ui()
	%Support_store_window.hide()
	$Close_UI_Button.pressed.connect(Check_container_action.bind($Close_UI_Button.name,"Pressed"))
	%Close_Info_Button.pressed.connect(Check_container_action.bind(%Close_Info_Button.name,"Pressed"))
	for boxes:VBoxContainer in %HBox_Buy_Placeables.get_children(true):
		for UI_elements:Control in boxes.get_children(true):
			if UI_elements is Button:
				UI_elements.pressed.connect(Check_container_action.bind(UI_elements.name,"Pressed"))
				if UI_elements.name.contains("Buy"):
					UI_elements.mouse_entered.connect(Check_container_action.bind(UI_elements.name,"Hover"))
	for Price_elements:Control in $Action_Container/VBoxContainer.get_children(true):
		if Price_elements.name.contains("Hover"):
			Price_elements.hide()

func Check_container_action(Button_name:String,Action:String) -> void:
	match Button_name:
		"Weapons_Buy_Button":
			if Action == "Pressed":
				check_buy_action.rpc("Buy_Weapons",Unique_player_ID)
			elif Action == "Hover":
				Display_purchase_info("Weapons")
		
		"Base_Buy_Button":
			if Action == "Pressed":
				check_buy_action.rpc("Buy_Base",Unique_player_ID)
			elif Action == "Hover":
				Display_purchase_info("Military Base")
		
		"Base_Place_Button":
			The_action.emit("Base_placing")
			find_child("Dynamic_Action").text = "Base placing" #Updates "Dynamic" UI with current action (building a base)
		
		"Fighter_Buy_Button":
			if Action == "Pressed":
				check_buy_action.rpc("Buy_Fighter",Unique_player_ID)
			elif Action == "Hover":
				Display_purchase_info("Fighter")
		
		"Fighter_Place_Button":
			The_action.emit("Fighter_placing")
			find_child("Dynamic_Action").text = "Fighter placing" #Updates "Dynamic" UI with current action (placing Figher)
		
		"Influence_Buy_Button":
			if Action == "Pressed":
				check_buy_action.rpc("Buy_Influence",Unique_player_ID)
			elif Action == "Hover":
				Display_purchase_info("Influence")
		
		"Influence_Place_Button":
			The_action.emit("Influence_placing")
			find_child("Dynamic_Action").text = "Influence placing" #Updates "Dynamic" UI with current action (placing Influence)
		
		"Intelligence_Network_Buy_Button":
			if Action == "Pressed":
				check_buy_action.rpc("Buy_Intel",Unique_player_ID)
			elif Action == "Hover":
				Display_purchase_info("Intelligence Network")
		
		"Intelligence_Network_Place_Button":
			The_action.emit("Intel_placing")
			find_child("Dynamic_Action").text = "Intelligence placing" #Updates "Dynamic" UI with current action (placing Intelligence Network)
		
		"Logistics_Network_Buy_Button":
			if Action == "Pressed":
				check_buy_action.rpc("Buy_Logs",Unique_player_ID)
			elif Action == "Hover":
				Display_purchase_info("Logistics Network")
		
		"Logistics_Network_Place_Button":
			The_action.emit("Logs_placing")
			find_child("Dynamic_Action").text = "Logistics placing" #Updates "Dynamic" UI with current action (placing Logistics Network)
			
		"Close_UI_Button":
			$Action_Container.visible = !$Action_Container.visible
			if $Action_Container.visible:
				$Close_UI_Button.position = Vector2(232,64)
				$Close_UI_Button.text = "<"
			else:
				$Close_UI_Button.position = Vector2(0,64)
				$Close_UI_Button.text = ">"
				
		"Close_Info_Button":
			%Player_Info.visible = !%Player_Info.visible
			if %Player_Info.visible:
				%Close_Info_Button.position = Vector2(610,0)
				%Close_Info_Button.text = "<"
			else:
				%Close_Info_Button.position = Vector2(0,0)
				%Close_Info_Button.text = ">"

#func _player_switch_ui() -> void:
	#$PanelContainer2/VBoxContainer/HSplitContainer/Dynamic_Player.text = Overseer.current_player

func _phase_switch_ui() -> void:
	match Overseer.current_phase:
		0:
			$Current_Phase.text = "Maintenence"
		1:
			$Current_Phase.text = "Purchase Units & Infrastructure"
		2:
			$Current_Phase.text = "Place Influence Units & Infrastructure"
		3:
			$Current_Phase.text = "Move Units"
		4:
			$Current_Phase.text = "Combat"
		5:
			$Current_Phase.text = "Placce Fighter Units & Bases"
		6:
			$Current_Phase.text = "Collect Resources"
			Overseer.Phase_cycle += 1
		7:
			$Current_Phase.text = "Muster forces"
		8:
			$Current_Phase.text = "UN Intervention"
	%Next_Phase_Button.set_pressed_no_signal(false)
	%Next_Phase_Button.text = "NEXT PHASE???"

@rpc("authority","call_local")
func action_error(error_message:String, player_ID:int) -> void:
	if multiplayer.get_unique_id() == player_ID: 
		$Error_Message.text = error_message
		$Error_Message.show()
		$Error_timer.start()

func _on_error_timer_timeout() -> void:
	$Error_Message.hide()

func _on_open_market_button_pressed() -> void:
	%Open_Market_Button.hide()
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
	%Player_Info/HBoxContainer/Guns.text = str(player.Weapons)
	%Player_Info/HBoxContainer/Money.text = str(player.Money)
	%Player_Info/HBoxContainer/Population.text = str(player.Man_power)
	%Player_Info/HBoxContainer/VictoryPoints.text = str(player.Victory_points)
	%Player_Info/HBoxContainer/Spacer2/Base_count.text = str(player.Player_storage["Military_Base"])
	%Player_Info/HBoxContainer/Spacer2/Fighter_count.text = str(player.Player_storage["Fighter"])
	%Player_Info/HBoxContainer/Spacer2/Influence_count.text = str(player.Player_storage["Influence"])
	%Player_Info/HBoxContainer/Spacer2/Intelligence_count.text = str(player.Player_storage["Intelligence"])
	%Player_Info/HBoxContainer/Spacer2/Logistics_count.text = str(player.Player_storage["Logistics"])

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	%Support_store_window.position = Vector2(975,36)

func _on_support_store_window_close_requested() -> void:
	%Support_store_window.hide()
	%Open_Market_Button.show()

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
	Overseer.change_phase.connect(Check_store_unlocked)
	Overseer.change_phase.connect(Update_available_buttons)
	Overseer.change_phase.connect(Overseer.Profit_and_Taxes)
	Unique_player_ID = multiplayer.get_unique_id()
	Update_available_buttons()

func update_node_unit_list(units:Array, mapnode:StringName) -> void:
	last_clicked_node = mapnode
	reset_node_unit_list()
	var player_unit_count:int = 0
	var enemy_unit_count:int = 0
	for unit:Resource in units:
		if unit.player_ID == multiplayer.get_unique_id():
			var new_unit_display:Control = UI_Unit_Scene.instantiate()
			new_unit_display.unit_resource = unit
			new_unit_display.source_node = str(mapnode)
			new_unit_display.move_unit.connect(move_unit_function)
			new_unit_display.attmepted_reconstitution.connect(Call_reconst_function)
			new_unit_display.set_color(unit.color)
			new_unit_display.set_type(unit.unit_type)
			new_unit_display.Check_unit_phase()
			%Unit_Display.add_child(new_unit_display)
			player_unit_count+=1
			#if unit.disrupted:
				#new_unit_display.enable_reconstitution()
		else:
			enemy_unit_count+=1
	if player_unit_count > 0 and enemy_unit_count > 0:
		%Attack_Button.disabled = false
	else:
		%Attack_Button.disabled = true

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
	if Meets_condition >= 1 && Overseer.current_phase == Overseer.PURCHASE:
		%Open_Market_Button.set_disabled(false)
	else:
		if !%Open_Market_Button.is_visible():
			%Open_Market_Button.show()
		%Open_Market_Button.set_disabled(true)
		$Support_store_window.hide()

@rpc("any_peer","call_local")
func check_buy_action(Buyable:String,Player_ID:int) -> void:
	if multiplayer.is_server():
		var Current_player:Resource = Overseer.Identify_player(Player_ID)
		match Buyable:
			"Buy_Weapons":
				if Current_player.Money >= 8 && Current_player.Player_faction == 1:
					Current_player.Money -= 8
					Current_player.Weapons += 1
					Overseer.Resources_to_rpc()
				
				elif Current_player.Money >= 5 && Current_player.Player_faction == 0:
					Current_player.Money -= 5
					Current_player.Weapons += 1
					Overseer.Resources_to_rpc()
				
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Unique_player_ID)
			
			"Buy_Base":
				if Current_player.Man_power >= 17 && Current_player.Money >= 45 && Current_player.Player_faction == 1:
					Current_player.Man_power -= 17
					Current_player.Money -= 45
					Current_player.Player_storage["Military_Base"] += 1
					Overseer.Resources_to_rpc()
				
				elif Current_player.Man_power >= 10 && Current_player.Money >= 30 && Current_player.Player_faction == 0:
					Current_player.Man_power -= 10 
					Current_player.Money -= 30
					Current_player.Player_storage["Military_Base"] += 1
					Overseer.Resources_to_rpc()
				
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
			"Buy_Fighter":
				if Current_player.Man_power >= 8 && Current_player.Money >= 15 && Current_player.Weapons >= 8 && Current_player.Player_faction == 1:
					Current_player.Man_power -= 8 
					Current_player.Money -= 15 
					Current_player.Weapons -= 8
					Current_player.Player_storage["Fighter"] += 1
					Overseer.Resources_to_rpc()
				
				elif Current_player.Man_power >= 5 && Current_player.Money >= 10 && Current_player.Weapons >= 5 && Current_player.Player_faction == 0:
					Current_player.Man_power -= 5 
					Current_player.Money -= 10 
					Current_player.Weapons -= 5
					Current_player.Player_storage["Fighter"] += 1
					Overseer.Resources_to_rpc()
				
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
			"Buy_Influence":
				if Current_player.Man_power >= 8 && Current_player.Money >= 25 && Current_player.Player_faction == 1:
					Current_player.Man_power -= 8 
					Current_player.Money -= 25
					Current_player.Player_storage["Influence"] += 1
					Overseer.Resources_to_rpc()
				
				elif Current_player.Man_power >= 5 && Current_player.Money >= 15 && Current_player.Player_faction == 0:
					Current_player.Man_power -= 5 
					Current_player.Money -= 15
					Current_player.Player_storage["Influence"] += 1
					Overseer.Resources_to_rpc()
				
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
			"Buy_Intel":
				if Current_player.Man_power >= 2 && Current_player.Money >= 15 && Current_player.Player_faction == 1:
					Current_player.Man_power -= 2 
					Current_player.Money -= 15
					Current_player.Player_storage["Intelligence"] += 1
					Overseer.Resources_to_rpc()
				
				elif Current_player.Man_power >= 1 && Current_player.Money >= 10 && Current_player.Player_faction == 0:
					Current_player.Man_power -= 1 
					Current_player.Money -= 10
					Current_player.Player_storage["Intelligence"] += 1
					Overseer.Resources_to_rpc()
				
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)
			
			"Buy_Logs":
				if Current_player.Man_power >= 2 && Current_player.Money >= 10 && Current_player.Player_faction == 1:
					Current_player.Man_power -= 2 
					Current_player.Money -= 10
					Current_player.Player_storage["Logistics"] += 1
					Overseer.Resources_to_rpc()
				
				elif Current_player.Man_power >= 1 && Current_player.Money >= 5 && Current_player.Player_faction == 0:
					Current_player.Man_power -= 1 
					Current_player.Money -= 5
					Current_player.Player_storage["Logistics"] += 1
					Overseer.Resources_to_rpc()
				
				else:
					action_error.rpc("You do not have enough resoucres to buy this!",Player_ID)

func Display_purchase_info(Item_name:String) -> void:
	$Action_Container/VBoxContainer/Purchase_Hover_Text.show()
	$Action_Container/VBoxContainer/Purchase_Hover_Image.show()
	$Action_Container/VBoxContainer/Purchase_Hover_Price.show()
	var Faction:int = Overseer.Identify_player(Unique_player_ID).Player_faction
	for Elements:Control in $Action_Container/VBoxContainer/Purchase_Hover_Price.get_children():
		Elements.hide()
	if Item_name == "Weapons":
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Image.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.show()
	elif Item_name == "Fighter":
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Image.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Image.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Guns_Image.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Guns_Cost.show()
	else:
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Image.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Image.show()
		$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.show()
	match Item_name:
		"Weapons":
			if Faction == 1:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "8"
			elif Faction == 0:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "5"
			$Action_Container/VBoxContainer/Purchase_Hover_Image/Item_picture.set_texture(Preview_placables[0])
		
		"Military Base":
			if Faction == 1:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "45"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "17"
			elif Faction == 0:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "30"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "10"
			$Action_Container/VBoxContainer/Purchase_Hover_Image/Item_picture.set_texture(Preview_placables[1])
		
		"Fighter":
			if Faction == 1:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text =  "15"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "8"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Guns_Cost.text = "8"
			elif Faction == 0:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "10"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "5"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Guns_Cost.text = "5"
			$Action_Container/VBoxContainer/Purchase_Hover_Image/Item_picture.set_texture(Preview_placables[2])
		
		"Influence":
			if Faction == 1:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "25"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "8"
			elif Faction == 0:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "15"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "5"
			$Action_Container/VBoxContainer/Purchase_Hover_Image/Item_picture.set_texture(Preview_placables[3])
		
		"Intelligence Network":
			if Faction == 1:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "15"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "2"
			elif Faction == 0:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "10"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "1"
			$Action_Container/VBoxContainer/Purchase_Hover_Image/Item_picture.set_texture(Preview_placables[4])
		
		"Logistics Network":
			if Faction == 1:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "10"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "2"
			elif Faction == 0:
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Money_Cost.text = "5"
				$Action_Container/VBoxContainer/Purchase_Hover_Price/Population_Cost.text = "1"
			$Action_Container/VBoxContainer/Purchase_Hover_Image/Item_picture.set_texture(Preview_placables[5])
	
	$Action_Container/Purchase_preview_timer.start()
	$Action_Container/VBoxContainer/Purchase_Hover_Text/Item_Name.text = Item_name

func _on_purchase_preview_timer_timeout() -> void:
	$Action_Container/VBoxContainer/Purchase_Hover_Text.hide()
	$Action_Container/VBoxContainer/Purchase_Hover_Image.hide()
	$Action_Container/VBoxContainer/Purchase_Hover_Price.hide()

func _on_next_phase_button_toggled(toggled_on: bool) -> void:
	if Overseer.current_phase == Overseer.INITIAL_DEPLOY:
		Check_completed_setup.rpc(multiplayer.get_unique_id(),toggled_on)
	else:
		if toggled_on:
			%Next_Phase_Button.text = "YES!"
		else:
			%Next_Phase_Button.text = "NO!"
		Overseer.Update_player_ready.rpc(multiplayer.get_unique_id(),toggled_on)

func Update_available_buttons() -> void:
	if Overseer.current_phase == Overseer.INTERVENTION:
		Change_available_buttons(true,true,true)
		%Next_Phase_Button.set_disabled(true)
	elif Overseer.current_phase == Overseer.INITIAL_DEPLOY:
		Change_available_buttons(true,false,false)
	elif Overseer.current_phase == Overseer.PURCHASE:
		Change_available_buttons(false,true,true)
	elif Overseer.current_phase == Overseer.PLACE_INFRASTRUCTURE:
		Change_available_buttons(true,true,false)
	elif Overseer.current_phase == Overseer.PLACE_MILITARY:
		Change_available_buttons(true,false,true)
	else:
		Change_available_buttons(true,true,true)
	if Overseer.current_phase != Overseer.PURCHASE:
		%Trade.hide()

func Change_available_buttons(Purchase:bool, Military:bool, Infrastructure:bool) -> void:
	get_tree().call_group("PURCHASE_PHASE_BUTTONS","set_disabled",Purchase)
	get_tree().call_group("PLACE_MILITARY_PHASE_BUTTON","set_disabled",Military)
	get_tree().call_group("PLACE_INFRASTRUCTURE_PHASE_BUTTON","set_disabled",Infrastructure)

@rpc("any_peer","call_local")
func Check_completed_setup(Requester_ID:int,Button_status:bool) -> void:
	if multiplayer.is_server():
		var Requester:Resource = Overseer.Identify_player(Requester_ID)
		if Requester.Player_storage.values().max() == 0:
			Finished_setup_check.rpc(Requester_ID,Button_status,true)
		else:
			Finished_setup_check.rpc(Requester_ID,Button_status,false)
			action_error.rpc("You need to place all infastructure & units down first!",Requester.Player_ID)

@rpc("authority","call_local")
func Finished_setup_check(OG_requester:int,toggel_status:bool,move_on:bool) -> void:
	if multiplayer.get_unique_id() == Overseer.Identify_player(OG_requester).Player_ID:
		if !move_on:
			%Next_Phase_Button.set_pressed_no_signal(false)
		else:
			if toggel_status:
				%Next_Phase_Button.text = "YES!"
			else:
				%Next_Phase_Button.text = "NO!"
			Overseer.Update_player_ready.rpc(multiplayer.get_unique_id(),toggel_status)

@rpc("any_peer","call_local")
func request_pre_combat_ui(map_node_path:NodePath) -> void:
	if multiplayer.is_server():
		var player_id:int = multiplayer.get_remote_sender_id() # attacker ID
		var map_node:Node = get_node(map_node_path)
		print(map_node.unit_list)
		var fighter_count:int = 0
		var influence_count:int = 0 
		var players_involved:Array
		for unit:Resource in map_node.unit_list:
			if unit.player_ID != player_id and not players_involved.has(unit.player_ID):
				players_involved.append(unit.player_ID)
			if unit.player_ID == player_id:
				if unit.unit_type == 0:
					fighter_count +=1
				else:
					influence_count +=1
		display_pre_combat.rpc(player_id, fighter_count, influence_count,players_involved)

@rpc("authority", "call_local")
func display_pre_combat(id:int, fighter_count:int, influence_count:int,players_involved:Array) -> void:
	if multiplayer.get_unique_id() == id:
		$Pre_Combat.set_counts(fighter_count, influence_count,players_involved)
		hide_ui()
		hidden_ui_nodes.erase($Pre_Combat)
		$Pre_Combat.show()


func _on_attack_button_pressed() -> void:
	var map_node:NodePath =get_parent().find_child(last_clicked_node).get_path()
	request_pre_combat_ui.rpc(map_node)
	
func _on_precombat_initialize(attacking_fighters:int, attacking_influence:int, target_player_id: int) -> void:
	var map_node:NodePath =get_parent().find_child(last_clicked_node).get_path()
	print(attacking_fighters)
	print(attacking_influence)
	print(target_player_id)
	_request_combat.rpc(attacking_fighters,attacking_influence,target_player_id,map_node)

@rpc("any_peer", "call_local", "reliable")
func _request_combat(attacking_fighters:int, attacking_influence:int, target_player_id: int, map_node_path:NodePath) -> void:
	if multiplayer.is_server():
		var player_id: int = multiplayer.get_remote_sender_id()
		if player_id == 0:
			player_id = multiplayer.get_unique_id()
		var map_node:Node = get_node(map_node_path)
		var attacking_fighters_found:Array = []
		var attacking_influence_found:Array = []
		var defending_units:Array = []
		for unit:Resource in map_node.unit_list:
			if unit.player_ID == player_id:
				if unit.unit_type == 0:
					attacking_fighters_found.append(unit)
				else:
					attacking_influence_found.append(unit)
			if unit.player_ID == target_player_id:
				defending_units.append(unit)
		if attacking_fighters_found.size() < attacking_fighters || attacking_influence_found.size() < attacking_influence: #check if client is lying
			print("bad combat request. attacking fighters: " + str(attacking_fighters) + ", but fighters found: "+ str(attacking_fighters_found.size()))
			return
		
		#var final_attacking_units:Array = attacking_fighters_found.slice(0, attacking_fighters-1) + attacking_influence_found.slice(0, attacking_influence-1) 
		var final_attacking_units: Array = []
		for i: int in range(min(attacking_fighters, attacking_fighters_found.size())):
			final_attacking_units.append(attacking_fighters_found[i])
		for i: int in range(min(attacking_influence, attacking_influence_found.size())):
			final_attacking_units.append(attacking_influence_found[i])
			
		Overseer.defending_units = defending_units
		Overseer.attacking_units = final_attacking_units
		Overseer.map_node_path = map_node_path
		print(final_attacking_units)
		_initialize_combat.rpc(player_id,target_player_id,attacking_fighters, attacking_influence, map_node_path )
	

@rpc("any_peer", "call_local", "reliable")
func _initialize_combat(attacker_id:int, defender_id:int, attacking_fighters:int, attacking_influence:int, map_node_path:NodePath) -> void:
	var map_node:Node = get_node(map_node_path)
	var attacking_units:Array = []
	var defending_units:Array = []
	var attacking_fighters_collected:int = 0
	var attacking_influence_collected:int = 0
	for unit:Resource in map_node.unit_list:
			if unit.player_ID == attacker_id:
				if unit.unit_type == 0 && (attacking_fighters_collected < attacking_fighters):
					attacking_units.append(unit)
					attacking_fighters_collected += 1
				elif unit.unit_type == 1 && (attacking_influence_collected < attacking_influence):
					attacking_units.append(unit)
					attacking_influence_collected += 1
			elif unit.player_ID == defender_id:
				defending_units.append(unit)
	var attacking_player:Resource = Overseer.Identify_player(attacker_id)
	var defending_player:Resource = Overseer.Identify_player(defender_id)
	Overseer.attacking_player = attacker_id
	Overseer.defending_player = defender_id
	Overseer.attacker_ready = false
	Overseer.defender_ready = false
	%Combat.my_id = multiplayer.get_unique_id()
	if multiplayer.get_unique_id() != defender_id: #attacker
		%Combat.set_counts(attacking_player.Weapons, attacking_player.Money,attacking_player.Man_power)
		%Combat.set_opposition_counts(defending_player.Weapons,defending_player.Money,defending_player.Man_power)
		if multiplayer.get_unique_id() != attacker_id: #spectators 
			%Combat.switch_player_type(1)
		else:
			%Combat.switch_player_type(0)
		%Combat.left_side_player_id = attacker_id
		%Combat.right_side_player_id = defender_id
		%Combat.swap_header(false)
		%Combat.display_allies(attacking_units)
		%Combat.display_opposition(defending_units)
	else: #defender
		%Combat.set_counts(defending_player.Weapons, defending_player.Money,defending_player.Man_power)
		%Combat.set_opposition_counts(attacking_player.Weapons, attacking_player.Money,attacking_player.Man_power)
		%Combat.switch_player_type(0)
		%Combat.left_side_player_id = defender_id
		%Combat.right_side_player_id = attacker_id
		%Combat.swap_header(true)
		%Combat.display_allies(defending_units)
		%Combat.display_opposition(attacking_units)
	
	hide_ui()
	hidden_ui_nodes.erase(%Combat)
	%Combat.pixel_fade_in()
	%Pre_Combat.hide()
	
func hide_ui() -> void:
	for node in get_children():
		if node is CanvasItem and node.visible:
			hidden_ui_nodes.append(node)
			node.visible = false

func show_ui() -> void:
	#print(hidden_ui_nodes)
	for node in hidden_ui_nodes:
		node.visible = true
	hidden_ui_nodes.clear()

func _on_precombat_cancel() -> void:
	show_ui()
	$Pre_Combat.hide()

func _return_ui_after_combat() -> void:
	update_Player_Info()
	show_ui()
	%Combat.pixel_fade_out()
	%Pre_Combat.hide()

func Call_reconst_function(Player_ID:int,units_type:int,unit_ID:String,node_name:String) -> void:
	Reconstitution_possible.rpc(Player_ID,units_type,unit_ID,node_name)

@rpc("any_peer","call_local")
func Reconstitution_possible(Caller_ID:int,unit_type:int,unit_UUID:String,node_name:String) -> void:
	if multiplayer.is_server():
		var Player_resource:Resource = Overseer.Identify_player(Caller_ID)
		var Edited_node:Node = get_parent().find_child(node_name)
		var checked_unit:Resource
		for units:Resource in Edited_node.unit_list:
			if units.disrupted and units.unit_UUID == unit_UUID:
				checked_unit =  units
		if checked_unit:
			match unit_type:
				0:
					if Player_resource.Player_faction == 1:
						if Player_resource.Man_power >= 4 and Player_resource.Money >= 8 and Player_resource.Weapons >= 4:
							Player_resource.Man_power -= 4
							Player_resource.Money -= 8
							Player_resource.Weapons -= 4
							Edited_node.remove_unit(Player_resource.Player_ID,0,true,checked_unit.unit_UUID)
							Edited_node.add_unit(Player_resource.Player_ID,0,Player_resource.color,checked_unit.unit_UUID,false,false,true)
							Overseer.Request_node_data(node_name)
							Overseer.Resources_to_rpc()
					else:
						if Player_resource.Man_power >= 3 and Player_resource.Money >= 5 and Player_resource.Weapons >= 3:
							Player_resource.Man_power -= 3
							Player_resource.Money -= 5
							Player_resource.Weapons -= 3
							Edited_node.remove_unit(Player_resource.Player_ID,0,true,checked_unit.unit_UUID)
							Edited_node.add_unit(Player_resource.Player_ID,0,Player_resource.color,checked_unit.unit_UUID,false,false,true)
							Overseer.Request_node_data(node_name)
							Overseer.Resources_to_rpc()
				1:
					if Player_resource.Player_faction == 1:
						if Player_resource.Man_power >= 4 and Player_resource.Money >= 13:
							Player_resource.Man_power -= 4
							Player_resource.Money -= 13
							Edited_node.remove_unit(Player_resource.Player_ID,1,true,checked_unit.unit_UUID)
							Edited_node.add_unit(Player_resource.Player_ID,1,Player_resource.color,checked_unit.unit_UUID,false,false,true)
							Overseer.Request_node_data(node_name)
							Overseer.Resources_to_rpc()
					else:
						if Player_resource.Man_power >= 3 and Player_resource.Money >= 8:
							Player_resource.Man_power -= 3
							Player_resource.Money -= 8
							Edited_node.remove_unit(Player_resource.Player_ID,1,true,checked_unit.unit_UUID)
							Edited_node.add_unit(Player_resource.Player_ID,1,Player_resource.color,checked_unit.unit_UUID,false,false,true)
							Overseer.Request_node_data(node_name)
							Overseer.Resources_to_rpc()
		else:
			print("\nSomething is worong here...\n")

	

# Weapons Money Man_power
			#action_error.rpc("You somehow have a unit that is not in the gmae, congrats!",Caller_ID)


func _on_open_trade_button_pressed() -> void:
	var player:Player = Overseer.Identify_player(multiplayer.get_unique_id())
	%Trade.set_counts(player.Weapons,player.Money,player.Man_power)
	%Trade.show()
