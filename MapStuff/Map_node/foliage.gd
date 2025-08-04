extends Node2D

	
func _ready() -> void:
	var foliage_array:Array = [
		preload("res://Assets/Map_Tiles/Foliage/Ferns_0.png"),
		preload("res://Assets/Map_Tiles/Foliage/Ferns_1.png"),
		preload("res://Assets/Map_Tiles/Foliage/Ferns_2.png"),
		preload("res://Assets/Map_Tiles/Foliage/Ferns_3.png")
		]
	var random_index:int = randi() % foliage_array.size()
	var selected_sprite:Texture= foliage_array[random_index]
	$Foliage.texture = selected_sprite
