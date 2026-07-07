extends Node

enum ButtonState {
	NORMAL,
	HOVER,
	PRESSED,
	DISABLED,
}

const BUTTON_SHADER := preload("res://Assets/Shaders/Button_Glow.gdshader")
const STYLED_GROUP := &"PROCEDURAL_SHADER_BUTTONS"
const OPT_OUT_GROUP := &"NO_PROCEDURAL_BUTTON_STYLE"
const MATERIAL_META := &"button_shader_material"
const POINTER_STATE_META := &"button_shader_pointer_state"

var _empty_button_style: StyleBoxEmpty


func _ready() -> void:
	_empty_button_style = StyleBoxEmpty.new()
	_empty_button_style.content_margin_left = 6.0
	_empty_button_style.content_margin_top = 3.0
	_empty_button_style.content_margin_right = 6.0
	_empty_button_style.content_margin_bottom = 3.0

	get_tree().node_added.connect(_on_node_added)
	for node: Node in get_tree().get_nodes_in_group(&"Buttons"):
		if node is Button:
			style_button(node)
	_style_existing_buttons(get_tree().root)


func _process(_delta: float) -> void:
	for button: Button in get_tree().get_nodes_in_group(STYLED_GROUP):
		var material := button.get_meta(MATERIAL_META) as ShaderMaterial
		if material == null:
			continue
		var pointer_state := int(button.get_meta(POINTER_STATE_META, ButtonState.NORMAL))
		var displayed_state := ButtonState.DISABLED if button.disabled else pointer_state
		if int(material.get_shader_parameter("state")) != displayed_state:
			material.set_shader_parameter("state", displayed_state)


func _on_node_added(node: Node) -> void:
	if node is Button:
		style_button.call_deferred(node)


func _style_existing_buttons(node: Node) -> void:
	if node is Button:
		style_button(node)
	for child: Node in node.get_children():
		_style_existing_buttons(child)


func style_button(button: Button) -> void:
	if not is_instance_valid(button):
		return
	if button.is_in_group(OPT_OUT_GROUP) or button.has_node("HoverGlow_ColorRect"):
		return
	for style_name: StringName in [&"normal", &"hover", &"pressed", &"disabled", &"focus"]:
		button.add_theme_stylebox_override(style_name, _empty_button_style)

	var background := ColorRect.new()
	background.name = "HoverGlow_ColorRect"
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.color = Color.WHITE
	background.z_index = -1

	var material := ShaderMaterial.new()
	material.shader = BUTTON_SHADER
	material.set_shader_parameter(
		"state",
		ButtonState.DISABLED if button.disabled else ButtonState.NORMAL
	)
	background.material = material

	button.add_to_group(STYLED_GROUP)
	button.set_meta(MATERIAL_META, material)
	button.set_meta(POINTER_STATE_META, ButtonState.NORMAL)
	button.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.clip_contents = true

	button.mouse_entered.connect(_set_state.bind(button, material, ButtonState.HOVER))
	button.mouse_exited.connect(_set_state.bind(button, material, ButtonState.NORMAL))
	button.button_down.connect(_set_state.bind(button, material, ButtonState.PRESSED))
	button.button_up.connect(_set_state.bind(button, material, ButtonState.HOVER))
	button.resized.connect(_update_button_size.bind(button, material))
	_update_button_size(button, material)


func set_button_state(button: Button, state: ButtonState) -> void:
	var material := button.get_meta(MATERIAL_META, null) as ShaderMaterial
	if material != null:
		_set_state(button, material, state)


func _set_state(button: Button, material: ShaderMaterial, state: ButtonState) -> void:
	if state == ButtonState.HOVER \
			and not button.get_global_rect().has_point(button.get_global_mouse_position()):
		state = ButtonState.NORMAL
	button.set_meta(POINTER_STATE_META, state)
	material.set_shader_parameter(
		"state",
		ButtonState.DISABLED if button.disabled else state
	)


func _update_button_size(button: Button, material: ShaderMaterial) -> void:
	var safe_width := maxf(button.size.x, 1.0)
	var safe_height := maxf(button.size.y, 1.0)
	material.set_shader_parameter("aspect_ratio", safe_width / safe_height)
	material.set_shader_parameter("button_size", Vector2(safe_width, safe_height))
