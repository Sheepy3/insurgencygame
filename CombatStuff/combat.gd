extends Control



func set_counts(fighter_max: int, influence_max:int) -> void:
	%Fighter_slider.max_value = fighter_max
	%Influence_slider.max_value = influence_max
	pass


func kill() -> void:
	queue_free()
