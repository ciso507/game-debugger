@tool
extends GameDebuggerOption

var text_edit_option: Control
var array_string_hint: Array
var array_packed_string: PackedStringArray
var use_array_type: String = ""
var current_array_type: String
var button_: Button

var red_style: StyleBoxFlat
var green_style: StyleBoxFlat


func _enter_tree() -> void:
	if get_parent() and get_parent().get_parent() and get_parent().get_parent().get_parent():
		text_edit_option = get_parent().get_parent().get_parent().get_node_or_null("TextEditOption")
	button_ = get_child(1) as Button


func _ready() -> void:
	super()
	setup_styles()
	button_ = get_child(1) as Button
	set_outline_red()


func setup_styles() -> void:
	red_style = StyleBoxFlat.new()
	red_style.bg_color = Color(0.38, 0.1, 0.12, 1.0)
	red_style.border_width_left = 3
	red_style.border_width_top = 3
	red_style.border_width_right = 3
	red_style.border_width_bottom = 3
	red_style.border_color = Color(1.0, 0.25, 0.25, 1.0)
	red_style.corner_radius_top_left = 4
	red_style.corner_radius_top_right = 4
	red_style.corner_radius_bottom_right = 4
	red_style.corner_radius_bottom_left = 4

	green_style = StyleBoxFlat.new()
	green_style.bg_color = Color(0.1, 0.35, 0.15, 1.0)
	green_style.border_width_left = 3
	green_style.border_width_top = 3
	green_style.border_width_right = 3
	green_style.border_width_bottom = 3
	green_style.border_color = Color(0.3, 1.0, 0.4, 1.0)
	green_style.corner_radius_top_left = 4
	green_style.corner_radius_top_right = 4
	green_style.corner_radius_bottom_right = 4
	green_style.corner_radius_bottom_left = 4


func set_outline_red() -> void:
	button_ = get_child(1) as Button
	if is_instance_valid(button_):
		if red_style == null:
			setup_styles()
		button_.add_theme_stylebox_override("normal", red_style)
		button_.add_theme_stylebox_override("hover", red_style)
		button_.add_theme_stylebox_override("pressed", red_style)


func set_outline_green() -> void:
	button_ = get_child(1) as Button
	if is_instance_valid(button_):
		if green_style == null:
			setup_styles()
		button_.add_theme_stylebox_override("normal", green_style)
		button_.add_theme_stylebox_override("hover", green_style)
		button_.add_theme_stylebox_override("pressed", green_style)


func array_to_use(string_value: String) -> void:
	current_array_type = string_value
	var tag_name = get_child(0)
	tag_name.text = string_value
	button_ = get_child(1) as Button
	if is_instance_valid(button_):
		button_.text = "Create Items..."
		button_.disabled = false
	setup_styles()
	set_outline_red()


func _on_button_pressed() -> void:
	if not is_instance_valid(text_edit_option):
		if get_parent() and get_parent().get_parent() and get_parent().get_parent().get_parent():
			text_edit_option = get_parent().get_parent().get_parent().get_node_or_null("TextEditOption")

	if is_instance_valid(text_edit_option):
		text_edit_option.visible = !text_edit_option.visible
		text_edit_option.current_array_type = current_array_type
		if text_edit_option.visible and text_edit_option.has_method("align_to_setting_resource"):
			text_edit_option.align_to_setting_resource()


