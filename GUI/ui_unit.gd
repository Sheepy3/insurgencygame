extends PanelContainer
var FighterSprite:Texture2D = preload("res://Assets/Military/soldier.png")
var InfluenceSprite:Texture2D = preload("res://Assets/Military/binoculars.png")
var unit_resource: Resource
var source_node: String
var disrupted: bool
signal move_unit(unit_resource: Resource, source_node: String)

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
	set_color(unit_resource.color)
	if unit_resource.unit_type == unit_type.Fighter:
		%TextureRect.texture = FighterSprite
	else:
		%TextureRect.texture = InfluenceSprite

func _on_move_button_pressed() -> void:
	move_unit.emit(unit_resource, source_node)

@rpc("authority","call_local")
func Check_unit_phase()-> void:
	print("This is the current phase: "+str(Overseer.current_phase))
	if Overseer.current_phase == Overseer.UNIT_MOVEMENT:
		$VBoxContainer/Move_Button.set_disabled(false)
	elif Overseer.current_phase == Overseer.PURCHASE:
		$VBoxContainer/Reconstitution_Button.set_disabled(false)
	else:
		$VBoxContainer/Move_Button.set_disabled(true)
		$VBoxContainer/Reconstitution_Button.set_disabled(true)
func enable_reconstitution() -> void:
	%Move_Button.disabled = true
	%Reconstitution_Button.disabled = false
