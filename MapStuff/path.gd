extends Node2D
@export var connection:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(connection) # point towards connection
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
