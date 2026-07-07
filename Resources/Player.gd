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
@export var Player_stats:Dictionary = {
	"Earned_weapons":0, "Spent_weapons":0, "Earned_money":0, "Spent_money":0, "Earned_man_power":0, "Spent_man_power":0, 
	"Give_weapons":0, "Get_weapons":0, "Give_money":0, "Get_money":0, "Give_man_power":0, "Get_man_power":0,
	"Buy_base":0, "Place_base":0, "Buy_Intel":0, "Place_Intel":0, "Buy_Logs":0, "Place_Logs":0,
	"Buy_influence":0, "Place_influence":0, "Buy_fighter":0, "Place_fighter":0
	}
