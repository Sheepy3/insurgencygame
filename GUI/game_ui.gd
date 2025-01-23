extends CanvasLayer
signal The_action(action: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Error_Message.hide()
	show()
	Overseer.change_player.connect(_player_switch_ui)
	Overseer.change_phase.connect(_phase_switch_ui)
	Overseer.cycle_players()
	_phase_switch_ui()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	pass # Replace with function body.
	
func _player_switch_ui() -> void:
	$PanelContainer2/VBoxContainer/HSplitContainer/Dynamic_Player.text = Overseer.current_player
	
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
