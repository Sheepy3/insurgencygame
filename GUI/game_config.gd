extends CanvasLayer
var map_generator:PackedScene = preload("res://MapStuff/MapGeneration/map_generator.tscn")
var size:int = 2
@onready var client:Node = $Client


func _ready() -> void:
	client.lobby_joined.connect(_lobby_joined)
	multiplayer.peer_connected.connect(Add_player_resource)
	show()
	#_start_map_gen() #hardcoded disabling config menu
 


func _on_button_pressed() -> void:
	_start_map_gen()
	Overseer.cycle_players()
	
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
	#Add_player_resource(1)

func _lobby_joined(lobby:String) -> void:
	%Roomcode.text = lobby
	Add_player_resource(1)

func Add_player_resource(ID:int) -> void:
	if multiplayer.is_server():
		var Player_resource:Resource = Player.new()
		Player_resource.Player_ID = ID
		Overseer.player_list.append(Player_resource)
		Overseer.Resources_to_rpc()
		#Overseer.Player_rpc_info["Player " +str(ID)] = [Overseer.Player_resource.Player_ID,Overseer.Player_resource.Player_name,Overseer.Player_resource.color,Overseer.Player_resource.base_list,Overseer.Player_resource.Weapons,Overseer.Player_resource.Money,Overseer.Player_resource.Man_power,Overseer.Player_resource.Victory_points]
