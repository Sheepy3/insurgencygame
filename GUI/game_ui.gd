extends CanvasLayer
signal The_action(action: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
