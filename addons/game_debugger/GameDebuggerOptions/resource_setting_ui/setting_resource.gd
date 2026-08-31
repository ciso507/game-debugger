@tool
extends Control
class_name SettingResource



const HINT_STRING = preload("res://addons/game_debugger/GameDebuggerOptions/resource_setting_ui/hint_string.tscn")

var main_view:MainView
@export var resources_created:Array[CustomSetting]
var custom_setting_resource:CustomSetting
var res_prop:ResProperty



var preset: HBoxContainer:
	get:
		if is_instance_valid(preset):
			return preset
		return get_node_or_null("VBoxContainer/Preset") as HBoxContainer

var setting_name: HBoxContainer:
	get:
		if is_instance_valid(setting_name):
			return setting_name
		return get_node_or_null("VBoxContainer/SettingName") as HBoxContainer

var type: HBoxContainer:
	get:
		if is_instance_valid(type):
			return type
		return get_node_or_null("VBoxContainer/Type") as HBoxContainer

var usage: HBoxContainer:
	get:
		if is_instance_valid(usage):
			return usage
		return get_node_or_null("VBoxContainer/Usage") as HBoxContainer

var hint: HBoxContainer:
	get:
		if is_instance_valid(hint):
			return hint
		return get_node_or_null("VBoxContainer/Hint") as HBoxContainer

var default_value: HBoxContainer:
	get:
		if is_instance_valid(default_value):
			return default_value
		return get_node_or_null("VBoxContainer/DefaultValue") as HBoxContainer

var bool_value: HBoxContainer:
	get:
		if is_instance_valid(bool_value):
			return bool_value
		return get_node_or_null("VBoxContainer/BoolValue") as HBoxContainer

var array_value: HBoxContainer:
	get:
		if is_instance_valid(array_value):
			return array_value
		return get_node_or_null("VBoxContainer/ArrayValue") as HBoxContainer

var v_box_container: VBoxContainer:
	get:
		if is_instance_valid(v_box_container):
			return v_box_container
		return get_node_or_null("VBoxContainer") as VBoxContainer

var complete_message: HBoxContainer:
	get:
		if is_instance_valid(complete_message):
			return complete_message
		return get_node_or_null("CompleteMessage") as HBoxContainer

var current_text
var current_type
var current_usage
var current_hint

var packed_array
var string_hint_array

var text_edit_main
var fold_button: Button:
	get:
		if is_instance_valid(fold_button):
			return fold_button
		return get_node_or_null("VBoxContainer/FoldButton") as Button

var is_details_unfolded: bool = false
var hint_string
var status_label: Label 
var has_user_dragged: bool = false


func get_default_value_container() -> HBoxContainer:
	return default_value

func get_preset_container() -> HBoxContainer:
	return preset

func get_type_container() -> HBoxContainer:
	return get_node_or_null("VBoxContainer/Type") as HBoxContainer if get_node_or_null("VBoxContainer/Type") else type

func get_usage_container() -> HBoxContainer:
	return get_node_or_null("VBoxContainer/Usage") as HBoxContainer if get_node_or_null("VBoxContainer/Usage") else usage

func get_hint_container() -> HBoxContainer:
	return get_node_or_null("VBoxContainer/Hint") as HBoxContainer if get_node_or_null("VBoxContainer/Hint") else hint

func get_v_box_container() -> VBoxContainer:
	return v_box_container


func _ready() -> void:
	apply_info_panel_theme()
	if is_instance_valid(fold_button) and not fold_button.pressed.is_connected(_on_fold_button_pressed):
		fold_button.pressed.connect(_on_fold_button_pressed)
	_update_fold_visibility()



func _on_fold_button_pressed() -> void:
	is_details_unfolded = not is_details_unfolded
	_update_fold_visibility()


func _update_fold_visibility() -> void:
	var type_node = get_node_or_null("VBoxContainer/Type")
	var usage_node = get_node_or_null("VBoxContainer/Usage")
	var hint_node = get_node_or_null("VBoxContainer/Hint")

	if is_instance_valid(type_node):
		type_node.visible = is_details_unfolded
	if is_instance_valid(usage_node):
		usage_node.visible = is_details_unfolded
	if is_instance_valid(hint_node):
		hint_node.visible = is_details_unfolded

	var fb = fold_button
	if is_instance_valid(fb):
		if is_details_unfolded:
			fb.text = "▼"
		else:
			fb.text = "▶"





func select_option_by_text(container: HBoxContainer, text: String) -> void:
	if container == null:
		return
	var opt: OptionButton = container.get_node_or_null("OptionButton") as OptionButton
	if opt == null and container.get_child_count() > 1:
		opt = container.get_child(1) as OptionButton
	if opt == null:
		for c in container.get_children():
			if c is OptionButton:
				opt = c
				break
	if opt == null:
		return

	for i in range(opt.item_count):
		if opt.get_item_text(i) == text:
			opt.select(i)
			opt.selected = i
			opt.text = text
			break


func apply_preset(preset_name: String) -> void:
	var type_node = get_type_container()
	var usage_node = get_usage_container()
	var hint_node = get_hint_container()
	var preset_node = get_preset_container()

	select_option_by_text(preset_node, preset_name)

	match preset_name:
		"String":
			current_type = "String"
			current_usage = "Default"
			current_hint = "None"
			select_option_by_text(type_node, "String")
			select_option_by_text(usage_node, "Default")
			select_option_by_text(hint_node, "None")
			update_default_value("", Control.MOUSE_FILTER_STOP)
			update_string_default_value_style()
		"Enum":
			current_type = "String"
			current_usage = "Default"
			current_hint = "Enum"
			select_option_by_text(type_node, "String")
			select_option_by_text(usage_node, "Default")
			select_option_by_text(hint_node, "Enum")
			update_string_default_value_style()
		"Bool":
			current_type = "Bool"
			current_usage = "Default"
			current_hint = "None"
			select_option_by_text(type_node, "Bool")
			select_option_by_text(usage_node, "Default")
			select_option_by_text(hint_node, "None")
			update_string_default_value_style()

		"Array":
			current_type = "PackedStringArray"
			current_usage = "Default"
			current_hint = "TypeString"
			select_option_by_text(type_node, "PackedStringArray")
			select_option_by_text(usage_node, "Default")
			select_option_by_text(hint_node, "TypeString")
			update_string_default_value_style()
		"Int":
			current_type = "Int"
			current_usage = "Default"
			current_hint = "None"
			select_option_by_text(type_node, "Int")
			select_option_by_text(usage_node, "Default")
			select_option_by_text(hint_node, "None")
			update_string_default_value_style()
		"Float":
			current_type = "Float"
			current_usage = "Default"
			current_hint = "None"
			select_option_by_text(type_node, "Float")
			select_option_by_text(usage_node, "Default")
			select_option_by_text(hint_node, "None")
			update_string_default_value_style()
		_:
			pass

	_evaluate_current_state()


var red_style: StyleBoxFlat
var green_style: StyleBoxFlat


func setup_styles() -> void:
	if red_style == null:
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

	if green_style == null:
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


func update_string_default_value_style() -> void:
	setup_styles()
	var dv = get_default_value_container()
	if not is_instance_valid(dv):
		return

	var line_edit: LineEdit = dv.get_child(1) as LineEdit if dv.get_child_count() > 1 else null
	if not is_instance_valid(line_edit):
		return

	if not line_edit.text_changed.is_connected(_on_default_value_text_changed):
		line_edit.text_changed.connect(_on_default_value_text_changed)

	if current_type == "String" and current_hint == "None":
		if line_edit.text.strip_edges() == "":
			line_edit.add_theme_stylebox_override("normal", red_style)
		else:
			line_edit.add_theme_stylebox_override("normal", green_style)
	else:
		line_edit.remove_theme_stylebox_override("normal")


func _on_default_value_text_changed(_new_text: String) -> void:
	update_string_default_value_style()
	validate_setting()




func apply_info_panel_theme() -> void:
	var color_rect = get_node_or_null("ColorRect")
	if is_instance_valid(color_rect):
		color_rect.hide()

	var bg_panel = get_node_or_null("BGPanel") as Panel
	if bg_panel == null:
		bg_panel = Panel.new()
		bg_panel.name = "BGPanel"
		bg_panel.layout_mode = 1
		bg_panel.anchors_preset = 15
		bg_panel.anchor_right = 1.0
		bg_panel.anchor_bottom = 1.0
		bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg_panel)
		move_child(bg_panel, 0)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.22, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.65, 0.45, 0.95, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	bg_panel.add_theme_stylebox_override("panel", style)


func _enter_tree():
	apply_info_panel_theme()
	if get_parent():
		text_edit_main = get_parent().get_node_or_null("TextEditOption")
	res_prop = ResProperty.new()




func load_res(res) -> void:
	if is_instance_valid(main_view):
		resources_created = res
		notify_property_list_changed()


func update_text(_text):
	current_text = _text
	validate_setting()


func _update_current_values(text: String, type_enum: int) -> void:
	match type_enum:
		1:  # TYPE
			current_type = text
		2:  # USAGE
			current_usage = text
		3:  # HINT
			current_hint = text
		_:
			return

	_evaluate_current_state()


func _evaluate_current_state() -> void:
	var is_packed_string_array: bool = (current_type == "PackedStringArray" 
		and (current_hint == "TypeString" or current_hint == "None" or current_hint == ""))
	var is_enum_type: bool = (current_type == "String" and current_hint == "Enum")
	var is_numeric_type: bool = (current_type == "Int" or current_type == "Float")

	if is_enum_type:
		set_packed_hint_array("hint_string_array")
		create_hint_string(get_hint_container(), "HintStringArray")
		update_default_value()

	elif is_packed_string_array:
		set_packed_hint_array("packed_string_array")
		create_hint_string(get_hint_container(), "PackedStringArray")

	elif is_numeric_type:
		if is_instance_valid(hint_string):
			hint_string.queue_free()
		update_default_value()

	else:
		if is_instance_valid(hint_string):
			hint_string.queue_free()
		update_default_value()

	validate_setting()


func update_default_value(stringer := "false", mouse_filt := Control.MOUSE_FILTER_IGNORE,) -> void:
	var line_edit: LineEdit = default_value.get_child(1) as LineEdit
	line_edit.text = stringer
	default_value.mouse_filter = mouse_filt




func create_hint_string(hint_node: Node, String_value: String = "HintStringArray"):
	var vbox = get_v_box_container()
	if vbox == null:
		return

	if not is_instance_valid(hint_string):
		hint_string = HINT_STRING.instantiate()
		vbox.add_child(hint_string)
		hint_string.array_to_use(String_value)
		var target_hint = hint_node if is_instance_valid(hint_node) else get_hint_container()
		var hint_index = vbox.get_children().find(target_hint)
		if hint_index != -1:
			vbox.move_child(hint_string, hint_index + 1)


signal cancel_creation(stringer:String)

func _on_create_button_pressed() -> void:
	if main_view.current_settings == null:
		main_view.current_settings = []

	var new_setting: CustomSetting = CustomSetting.new()

	if not validate_setting(new_setting):
		return

	set_property_from_option(type, new_setting, "type", res_prop.TYPE_NAMES)
	set_property_from_option(usage, new_setting, "usage", res_prop.USAGE)
	set_property_from_option(hint, new_setting, "hint", res_prop.HINTS)

	main_view.current_settings.push_back(new_setting)
	notify_property_list_changed()

	set_array_type_text_option(new_setting)
	for i in main_view.current_settings:
		pass # print(i.name, "adding all of them")
	pass # print("✅ Added CustomSetting with type:", new_setting.type, "and name:", new_setting.name)

	main_view.save_resources_to_user(main_view.current_settings)
	main_view.update_plugin()

	await get_tree().create_timer(2.5).timeout
	status_label.text = "reading..."



	
	
func set_property_from_option(node_: Node, new_setting: CustomSetting, property_name: String, 
	mapping: Dictionary) -> void:
	# Get the OptionButton (assumes it's the second child)
	var option_button: OptionButton = node_.get_child(1) as OptionButton
	
	# Get selected index
	var selected_index: int = option_button.get_selected()
	
	# Get the corresponding value from the mapping
	var keys: Array = mapping.keys()
	if selected_index >= 0 and selected_index < keys.size():
		var selected_value = keys[selected_index]
		new_setting.set(property_name, selected_value)

		

func set_array_type_text_option(new_setting):
	var result_array = text_edit_main.array_to_use

	# Force conversion into Array[String]
	var array_string: Array[String] = []
	for item in result_array:
		array_string.append(str(item))

	# Force conversion into PackedStringArray
	var packed_array: PackedStringArray = []
	for item in result_array:
		packed_array.append(str(item))

	if result_array.size() > 0:
		new_setting.hint_string = array_string
		new_setting.array_value = packed_array


var gold_explanation_label: Label = null

func get_gold_explanation_label() -> Label:
	if not is_instance_valid(gold_explanation_label):
		gold_explanation_label = get_node_or_null("GoldExplanationLabel") as Label
		if gold_explanation_label == null:
			gold_explanation_label = Label.new()
			gold_explanation_label.name = "GoldExplanationLabel"
			gold_explanation_label.layout_mode = 0
			gold_explanation_label.position = Vector2(10, 445)
			gold_explanation_label.custom_minimum_size = Vector2(280, 30)
			gold_explanation_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0, 1.0))
			gold_explanation_label.add_theme_font_size_override("font_size", 12)
			gold_explanation_label.z_index = 100
			gold_explanation_label.z_as_relative = false
			add_child(gold_explanation_label)
	return gold_explanation_label


var can_create_setting = false
func validate_setting(new_setting: Resource = null) -> bool:
	# Get the user input name
	var retrieve_name: LineEdit = setting_name.get_child(1) as LineEdit
	var suffix_name: String = retrieve_name.text.strip_edges()

	status_label = complete_message.get_node("Label")
	var explanation_lbl = get_gold_explanation_label()

	# Use a default name if empty
	if suffix_name == "":
		suffix_name = "Setting_%d" % main_view.current_settings.size()

	var full_name: String = "Game/Debug/%s" % suffix_name

	var mark_invalid = func(explanation_text: String) -> bool:
		status_label.text = "Invalid"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
		explanation_lbl.text = "⚠ " + explanation_text
		return false

	# --- Check if setting already exists in ProjectSettings ---
	if ProjectSettings.has_setting(full_name):
		return mark_invalid.call("Invalid name (already exists in ProjectSettings)")

	# --- Check if setting already exists in current_settings ---
	for s in main_view.current_settings:
		if s and s.name == full_name:
			return mark_invalid.call("Invalid name (already exists in custom settings)")

	# --- Validate type + hint ---
	var valid_input: bool = (
		(current_type == "PackedStringArray")
		or (current_type == "Bool")
		or (current_type == "String")
		or (current_type == "Int")
		or (current_type == "Float")
	)

	if not valid_input:
		return mark_invalid.call("Invalid input type")

	# --- Check if plain String requires default value ---
	if current_type == "String" and current_hint == "None":
		var dv = get_default_value_container()
		if is_instance_valid(dv) and dv.get_child_count() > 1:
			var line_edit: LineEdit = dv.get_child(1) as LineEdit
			if is_instance_valid(line_edit) and line_edit.text.strip_edges() == "":
				update_string_default_value_style()
				return mark_invalid.call("Enter a default string value first!")

	# --- Check if Array / Enum requires item setup ---
	var requires_array_items: bool = (
		(current_type == "PackedStringArray" and current_hint == "TypeString")
		or (current_type == "String" and current_hint == "Enum")
	)

	if requires_array_items and is_instance_valid(text_edit_main):
		if text_edit_main.array_to_use.size() == 0:
			if is_instance_valid(hint_string) and hint_string.has_method("set_outline_red"):
				hint_string.set_outline_red()
			return mark_invalid.call("Click the Red button & add items first!")

	# ✅ Passed validation → Assign name to new setting
	if new_setting != null:
		new_setting.name = full_name

	status_label.text = "Valid"
	status_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45, 1.0))
	explanation_lbl.text = ""
	return true








func set_packed_hint_array(stringer:String):
	pass
	#if stringer == "hint_string":
		#string_hint_array



func _on_reset_button_pressed() -> void:
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	hide()
	if is_instance_valid(text_edit_main):
		text_edit_main.hide()

