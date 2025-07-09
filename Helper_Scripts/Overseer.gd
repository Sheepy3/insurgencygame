extends Node


#todo: convert player system to use resources for each player. these variables are gonna be unstable
#when networking is added, and the "current player" thing doesnt work if players take turns at the same time. 

var players:Array = ["Player 1", "Player 2"] #currently hardcoded, would be procedurally generated based on playercount
var players_colors:Array = [Vector3(1.0,0.0,0.0),Vector3(0.0,1.0,0.0)]
var selected_player_index:int = -1
var current_player:String
#var Mind_map:AStar2D = AStar2D.new()
var Logistics_map:AStar2D = AStar2D.new()
var Intelligence_map:AStar2D = AStar2D.new()
 
var base_list:Array

enum {MAINTENENCE, PURCHASE, PLACE_INFRA, UNIT_MOVEMENT,PLACE_MILITARY, COLLECT}
var current_phase:int = MAINTENENCE

signal change_player
signal change_phase

func cycle_players() -> void:
	var playerquant:int = players.size()-1
	if selected_player_index < playerquant:
		selected_player_index +=1
		current_player = players[selected_player_index]
		change_player.emit()
		print(selected_player_index)
	else:
		selected_player_index = 0
		current_player = players[selected_player_index]
		change_player.emit()
		print(selected_player_index)

func cycle_phases() -> void:
	print(current_phase)
	if current_phase < COLLECT:
		current_phase+=1
		change_phase.emit()
	else:
		current_phase = MAINTENENCE
		change_phase.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


const The_nodes = {
"1": [2, 4], 
"2": [1, 5],
"3": [4, 7],
"4": [1, 3, 8],
"5": [2, 6, 9],
"6": [5, 10],
"7": [3, 11],
"8": [4, 9, 12],
"9": [5, 8, 13],
"10": [6, 14],
"11": [7, 12, 15],
"12": [8, 11, 16],
"13": [9, 14, 17],
"14": [10, 13, 18],
"15": [11, 19],
"16": [12, 17, 20],
"17": [13, 16, 21],
"18": [14, 22],
"19": [15, 20],
"20": [16, 23],
"21": [17, 22, 24],
"22": [18, 21],
"23": [20, 24],
"24": [21, 23]
}
