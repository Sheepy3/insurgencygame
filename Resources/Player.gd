extends Resource
class_name Player
@export var Player_ID:int
@export var Player_name:String = ""
@export var color:Vector3 = Vector3(255, 255, 255)
@export var base_list:Array = []
@export var Weapons:int = 0 
@export var Money:int = 0
@export var Man_power:int = 0
@export var Victory_points:int = 0
@export var Player_storage:Dictionary = {"Units":[],"Buildings":[],"Networks":[]}
