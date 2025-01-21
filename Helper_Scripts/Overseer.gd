extends Node

var players:Array = ["Player 1", "Player 2"] #hardcoded, would be procedurally generated based on playercount
var players_colors:Array = ["#ff0000", "#0000ff"]
#to-do: add player colors 
enum {MAINTENENCE, PURCHASE, PLACE_INFRA, UNIT_MOVEMENT,PLACE_MILITARY, COLLECT}


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
