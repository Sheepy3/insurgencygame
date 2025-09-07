extends PanelContainer

@export var player_resource:Player


func _ready() -> void:
	pass
	
func _update_player_resource() -> void:
	pass
	
func update_color(colorvector:Vector3) -> void:
	#var colorvector:Vector3 = player_resource.color
	#print(colorvector.x)
	var color:Color = Color(colorvector.x,colorvector.y,colorvector.z,1)
	$Label.label_settings.font_color = color

func update_text(text:String) -> void:
	$Label.text = text
	
