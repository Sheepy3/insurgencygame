extends PanelContainer

@export var player_resource:Player


func _ready() -> void:
	#set player color based on player resource, which should be added to this node before added as a child
	_update_color()

func _update_player_resource() -> void:
	#get resource from player resource array in overseer and set player_resource to that resource, then call _update_color
	pass
	
func _update_color() -> void:
	var colorvector:Vector3 = player_resource.color
	print(colorvector.x)
	var color:Color = Color(colorvector.x,colorvector.y,colorvector.z,1)
	
	$Label.label_settings.font_color = color

func _update_text(text:String) -> void:
	$Label.text = text
