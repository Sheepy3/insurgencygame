extends Sprite2D
@export var rpu:Resource


func _ready() -> void:
	var RPU_array:Array = [
	preload("res://Assets/RPU_Tokens/0_1.png"),
	preload("res://Assets/RPU_Tokens/0_2.png"),
	preload("res://Assets/RPU_Tokens/0_3.png"),
	preload("res://Assets/RPU_Tokens/1_1.png"),
	preload("res://Assets/RPU_Tokens/1_2.png"),
	preload("res://Assets/RPU_Tokens/1_3.png"),
	]
	var random_index:int = randi() % RPU_array.size()
	match random_index:
		0:
			rpu.RPU = 1
			rpu.Population = 0
		1:
			rpu.RPU = 2
			rpu.Population = 0
		2:
			rpu.RPU = 3
			rpu.Population = 0
		3:
			rpu.RPU = 1
			rpu.Population = 1
		4:
			rpu.RPU = 2
			rpu.Population = 1
		5:
			rpu.RPU = 3
			rpu.Population = 1
		
	var selected_sprite:Texture= RPU_array[random_index]
	texture = selected_sprite
