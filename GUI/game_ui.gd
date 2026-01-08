extends CanvasLayer
signal The_action(action: String)
var Store_action: String = ""
var last_clicked_node:String = ""
var Unique_player_ID:int 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Error_Message.hide()
	#Overseer.change_player.connect(_player_switch_ui)
	Overseer.change_phase.connect(_phase_switch_ui)
	Overseer.game_started.connect(connect_update_UI)
	get_parent().find_child("Camera2D").clouds.connect(_toggle_clouds)
	#Overseer.cycle_players()
	_phase_switch_ui()
	%Support_store_window.hide()

#Activiates whe the "Place Base" button is pressed
func _on_base_button_pressed() -> void:
	The_action.emit("Base") #transmits signal that Base button has been pressed
	find_child("Dynamic_Action").text = "Base placing" #Updates "Dynamic" UI with current action (building a base)

#Activiates whe the "Figher" button is pressed
func _on_fighter_button_pressed() -> void:
	The_action.emit("Fighter") #transmits signal that Fighter button has been pressed
	find_child("Dynamic_Action").text = "Fighter placing" #Updates "Dynamic" UI with current action (placing Figher)

#Activiates whe the "Influence" button is pressed
func _on_influence_button_pressed() -> void:
	The_action.emit("Influence") #transmits signal that Base button has been pressed
	find_child("Dynamic_Action").text = "Influence placing" #Updates "Dynamic" UI with current action (placing Influence)

#Activiates whe the "Intelligence" button is pressed
func _on_intelligence_network_button_pressed() -> void:
	The_action.emit("Intelligence") #transmits signal that Intelligence button has been pressed
	find_child("Dynamic_Action").text = "Intelligence Network placing" #Updates "Dynamic" UI with current action (placing Intelligence Network)

#Activiates whe the "Logistics" button is pressed
func _on_logistics_network_button_pressed() -> void:
	The_action.emit("Logistics") #transmits signal that Logistics button has been pressed
	find_child("Dynamic_Action").text = "Logistics Network placing" #Updates "Dynamic" UI with current action (placing Logistics Network)

func _on_player_switch_button_pressed() -> void:
	pass
	#Overseer.cycle_players()

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

func action_error(error_message:String) -> void:
	$Error_Message.text = error_message
	$Error_Message.show()
	$Error_timer.start()

func _on_error_timer_timeout() -> void:
	$Error_Message.hide()

func _on_open_market_button_pressed() -> void:
	$Open_Market_Button.hide()
	%Support_store_window.show()

func _on_buy_button_pressed() -> void:
	Store_action = "Buy"

func _on_sell_button_pressed() -> void:
	Store_action = "Sell"

func _on_manpower_button_pressed() -> void:
	Manpower_action.rpc(Unique_player_ID,Store_action)

func _on_weapons_button_pressed() -> void:
	Weapons_action.rpc(Unique_player_ID,Store_action)

func update_Player_Info() -> void:
	var player:Resource = Overseer.Identify_player(Unique_player_ID) #Overseer.Identify_player(multiplayer.get_unique_id())
	$Player_Info/HBoxContainer/Guns.text = str(player.Weapons)
	$Player_Info/HBoxContainer/Money.text = str(player.Money)
	$Player_Info/HBoxContainer/Population.text = str(player.Man_power)

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

func select_node(tile:String) -> void:
	last_clicked_node = tile
	pass

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
			action_error("You do not have enough resources to complete this transaction!")

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
			action_error("You do not have enough resources to complete this transaction!")

func connect_update_UI() -> void:
	Overseer.player_resources_updated.connect(update_Player_Info)
	Unique_player_ID = multiplayer.get_unique_id()
