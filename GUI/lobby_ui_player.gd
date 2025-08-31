extends Control

@export var player_resource:Player


func _ready() -> void:
	#set player color based on player resource, which should be added to this node before added as a child
	pass
	var colorvector:Vector3 = player_resource.color
	print(colorvector.x)
	var color:Color = Color(colorvector.x,colorvector.y,colorvector.z,1)
	
	$PanelContainer/Label.label_settings.font_color = color
