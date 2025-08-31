extends CanvasLayer
signal The_action(action: String)
var Store_action: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Error_Message.hide()
	Overseer.change_player.connect(_player_switch_ui)
	Overseer.change_phase.connect(_phase_switch_ui)
	Overseer.cycle_players()
	_phase_switch_ui()
	%Support_store_window.hide()
	for Players: Resource in Overseer.player_list:
		Players.Money += 20
		Players.Man_power += 10

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
	Overseer.cycle_players()

func _player_switch_ui() -> void:
	$PanelContainer2/VBoxContainer/HSplitContainer/Dynamic_Player.text = Overseer.current_player
	update_Player_Info()

func _phase_switch_ui() -> void:
	match Overseer.current_phase:
		0:
			$Current_Phase.text = "Maintenence"
		1:
			$Current_Phase.text = "Purchase Units & Infrastructure"
		2:
			$Current_Phase.text = "Place Infrastructure"
		3:
			$Current_Phase.text = "Move Units"
		4:
			$Current_Phase.text = "Place Military Units & Infrastructure"
		5:
			$Current_Phase.text = "Collect Resources"

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
	var Player_resource: Resource = Overseer.player_list[Overseer.selected_player_index]
	if Store_action == "Buy" and Player_resource.Money >= 5:
		Player_resource.Man_power += 1
		Player_resource.Money -= 5
		Store_action = ""
	elif Store_action == "Sell" and Player_resource.Man_power >= 1:
		Player_resource.Man_power -= 1
		Player_resource.Money += 5
		Store_action = ""
	else: 
		action_error("You do not have enough resources to complete this transaction!")
	update_Player_Info()

func _on_weapons_button_pressed() -> void:
	var Player_resource: Resource = Overseer.player_list[Overseer.selected_player_index]
	if Store_action == "Buy" and Player_resource.Money >= 3:
		print("moneyt")
		Player_resource.Weapons += 1
		Player_resource.Money -= 3
		Store_action = ""
	elif Store_action == "Sell" and Player_resource.Weapons >= 1:
		Player_resource.Weapons -= 1
		Player_resource.Money += 3
		Store_action = ""
	else:
		action_error("You do not have enough resources to complete this transaction!")
	update_Player_Info()

func update_Player_Info() -> void:
	$Player_Info/HBoxContainer/Guns.text = str(Overseer.player_list[Overseer.selected_player_index].Weapons)
	$Player_Info/HBoxContainer/Money.text = str(Overseer.player_list[Overseer.selected_player_index].Money)
	$Player_Info/HBoxContainer/Population.text = str(Overseer.player_list[Overseer.selected_player_index].Man_power)

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	%Support_store_window.position = Vector2(975,36)

func _on_support_store_window_close_requested() -> void:
	%Support_store_window.hide()
	$Open_Market_Button.show()

func _on_support_store_window_window_input(event: InputEvent) -> void:
	$Store_bounds.global_position = %Support_store_window.position
