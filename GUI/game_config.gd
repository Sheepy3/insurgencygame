extends CanvasLayer
var map_generator:PackedScene = preload("res://MapStuff/MapGeneration/map_generator.tscn")
var size:int = 2
@onready var client:Node = $Client


func _ready() -> void:
	client.lobby_joined.connect(_lobby_joined)
	show()
	#_start_map_gen() #hardcoded disabling config menu
 


func _on_button_pressed() -> void:
	_start_map_gen()
	
func _start_map_gen() -> void:
	var spawn_map_generator:Node = map_generator.instantiate()
	spawn_map_generator.size = size 
	get_parent().add_child.call_deferred(spawn_map_generator)
	hide()
	

func _on_option_button_item_selected(index: int) -> void:
	size = index
	pass # Replace with function body.


func _on_join_button_pressed() -> void:
	client.start(%IP.text, %Room.text, true)


func _lobby_joined(lobby:String) -> void:
	print(lobby)
	%Room_Code.text = lobby
