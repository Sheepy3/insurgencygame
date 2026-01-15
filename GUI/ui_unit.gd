extends PanelContainer
var FighterSprite:Texture2D = preload("res://Assets/Military/soldier.png")
var InfluenceSprite:Texture2D = preload("res://Assets/Military/binoculars.png")
var Unit_Resource:Resource

signal Move_button(Unit_Data:Resource)

enum unit_type {
	Fighter,
	Influence,
}

func set_color(color:Vector3) -> void:
	%TextureRect.material.set_shader_parameter("tint_color", color)
	%TextureRect.material.set_shader_parameter("saturation", 0.7)
	pass
	
func set_type(type:int) -> void:
	if type == unit_type.Fighter:
		%TextureRect.texture = FighterSprite
	else:
		%TextureRect.texture = InfluenceSprite
	pass

func _ready() -> void:
	
	pass
	

func _on_unit_move_button_pressed() -> void:
	Move_button.emit(Unit_Resource)
	pass # Replace with function body.
