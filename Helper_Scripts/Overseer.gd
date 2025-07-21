extends Node

#todo: convert player system to use resources for each player. these variables are gonna be unstable
#when networking is added, and the "current player" thing doesnt work if players take turns at the same time. 

#var players:Array = ["Player 1", "Player 2"] #currently hardcoded, would be procedurally generated based on playercount
var players_colors:Array = [Vector3(1.0,0.0,0.0),Vector3(0.0,1.0,0.0)]
var player_list:Array
var Player_resource:Resource = load("res://Resources/Preset/Player_Default.tres")
var selected_player_index:int = -1
var current_player:String
var Logistics_map:AStar2D = AStar2D.new()
var Intelligence_map:AStar2D = AStar2D.new()
 
#var base_list:Array

enum {MAINTENENCE, PURCHASE, PLACE_INFRA, UNIT_MOVEMENT,PLACE_MILITARY, COLLECT}
var current_phase:int = MAINTENENCE

signal change_player
signal change_phase

func populate_player_list(Game_Size:int)-> void:
	for x:int in range(Game_Size):
		player_list.append(Player_resource.duplicate(true))
		Player_resource.color = players_colors[x]
		player_list[x].Player_name = "Player " + str(x+1)

func cycle_players() -> void:
	var playerquant:int = player_list.size()-1
	if selected_player_index < playerquant:
		selected_player_index +=1
		current_player = player_list[selected_player_index].Player_name
		change_player.emit()
	else:
		selected_player_index = 0
		current_player = player_list[selected_player_index].Player_name
		change_player.emit()

func cycle_phases() -> void:
	if current_phase < COLLECT:
		current_phase+=1
		change_phase.emit()
	else:
		current_phase = MAINTENENCE
		change_phase.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_player_list(2)
	print(player_list[0].color)
	print(player_list[1].color)

var The_nodes:Dictionary
