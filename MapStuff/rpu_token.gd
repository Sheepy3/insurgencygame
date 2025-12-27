extends Sprite2D
@export var rpu:Resource
var RPU_array:Array

func _ready() -> void:
	RPU_array = [
	preload("res://Assets/RPU_Tokens/0_1.png"),
	preload("res://Assets/RPU_Tokens/0_2.png"),
	preload("res://Assets/RPU_Tokens/0_3.png"),
	preload("res://Assets/RPU_Tokens/1_1.png"),
	preload("res://Assets/RPU_Tokens/1_2.png"),
	preload("res://Assets/RPU_Tokens/1_3.png"),
	]


func randomize(generation_seed:int, index:int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = generation_seed + index
	var random_index := rng.randi_range(0, RPU_array.size() - 1)
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
