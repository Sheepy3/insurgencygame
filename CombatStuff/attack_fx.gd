extends TextureRect
var rotation_deg:float
var movement_speed:float
enum visual_type {BINOCULARS,FLASH} 
enum visual_direction {LEFT,RIGHT}
var set_visual_type:int 
var set_direction:int
var binoculars_asset:Texture = preload("res://Assets/Military/binoculars_thrown.png")
var muzzle_flash_asset:Texture = preload("res://Assets/Military/muzzle_flash_1.png")

func _ready() -> void:
	if set_visual_type == visual_type.BINOCULARS:
		rotation_deg = 0.01
		movement_speed = 0.05
	else:
		rotation_deg = 0
		movement_speed = 0

func _process(delta: float) -> void:
	rotation_degrees += 0.01
	
func configure(set_visual_type:int, set_visual_direction:int) -> void:
	if set_visual_type == visual_type.BINOCULARS:
		texture = binoculars_asset
		pass
	if set_visual_type == visual_type.FLASH:
		texture = muzzle_flash_asset
		
	if set_visual_direction == visual_direction.LEFT: # moving to left from right
		flip_h = true
	else:
		flip_h = false
