extends Resource
class_name Unit
@export_enum("Fighter", "Influence") var unit_type: int
@export var unit_UUID:String
@export var disrupted:bool = false
@export var player_ID:int
@export var color:Vector3
@export var offcolor:bool
@export var been_reconstituted:bool = false
@export var has_moved:bool = false
@export var has_fought:bool = false
