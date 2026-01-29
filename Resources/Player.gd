extends Resource
class_name Player
@export var Player_ID:int
@export var Player_name:String = ""
@export_enum("Insurgent","State") var Player_faction:int = -1
@export var color:Vector3 = Vector3(255, 255, 255)
@export var base_list:Array = []
@export var Weapons:int = 0 
@export var Money:int = 0
@export var Man_power:int = 0
@export var Victory_points:int = 0
@export var Player_storage:Dictionary = {
	"Military_Base":0,
	"Fighter":0,
	"Influence":0,
	"Intelligence":0,
	"Logistics":0,
	}
@export var Ready:bool = false
