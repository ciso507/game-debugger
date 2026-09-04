@tool
class_name MainViewManager extends Control


const CHECK_BUTTON_OPTION:PackedScene = preload("res://addons/game_debugger/GameDebuggerOptions/check_button_option.tscn")
const INT_BUTTON_OPTION:PackedScene = preload("res://addons/game_debugger/GameDebuggerOptions/int_button.tscn")
const HINT_ENUM_OPTION:PackedScene = preload("res://addons/game_debugger/GameDebuggerOptions/hint_enum_option.tscn")
const ARRAY_BUTTON_OPTION:PackedScene = preload("res://addons/game_debugger/GameDebuggerOptions/array_button.tscn")
const TEXT_INPUT_OPTION:PackedScene = preload("res://addons/game_debugger/GameDebuggerOptions/resource_setting_ui/text_input.tscn")


@onready var main_center_container: CenterContainer = %MainCenterContainer

@onready var scroll_container: ScrollContainer = $ScrollContainerz
@onready var settings_fold_button: Button = get_node_or_null("SettingsFoldButton")
@onready var h_box_container: VBoxContainer = $ScrollContainerz/HBoxContainer
@onready var title_anime: AnimationPlayer = %TitleAnime
@onready var main_view: MainView
var is_settings_unfolded: bool = false



func _enter_tree() -> void:
	update_settings()


var tween: Tween


func _ready() -> void:
	if is_instance_valid(settings_fold_button) and not settings_fold_button.pressed.is_connected(_on_settings_fold_button_pressed):
		settings_fold_button.pressed.connect(_on_settings_fold_button_pressed)
	_update_fold_layout(false)


func _on_settings_fold_button_pressed() -> void:
	is_settings_unfolded = not is_settings_unfolded
	_update_fold_layout(true)


func _update_fold_layout(animate: bool = false) -> void:
	var scroll = $ScrollContainerz if has_node("ScrollContainerz") else null
	var panel_bg = get_node_or_null("SettingsPanelBG") as Control
	var fb = settings_fold_button
	if fb == null:
		fb = get_node_or_null("SettingsFoldButton")
	if fb == null and has_node("%SettingsFoldButton"):
		fb = get_node("%SettingsFoldButton")

	var count = h_box_container.get_child_count() if is_instance_valid(h_box_container) else 0

	if is_instance_valid(fb):
		fb.z_index = 100
		fb.z_as_relative = false
		fb.visible = (count >= 3)
		var target_text = "▲" if is_settings_unfolded else "▼"
		var target_size = Vector2(329.0, 240.0) if is_settings_unfolded else Vector2(329.0, 150.0)
		var bg_target_size = Vector2(339.0, 250.0) if is_settings_unfolded else Vector2(339.0, 160.0)
		var target_pos = Vector2(-140.0, -50.0) if is_settings_unfolded else Vector2(-140.0, -105.0)

		fb.text = target_text

		if animate and is_inside_tree():
			if is_instance_valid(tween) and tween.is_running():
				tween.kill()
			tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			if is_instance_valid(scroll):
				tween.tween_property(scroll, "size", target_size, 0.25)
			if is_instance_valid(panel_bg):
				tween.tween_property(panel_bg, "size", bg_target_size, 0.25)
			tween.tween_property(fb, "position", target_pos, 0.25)

			# Scale up and down bounce pulse animation on the fold arrow
			var scale_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			scale_tween.tween_property(fb, "scale", Vector2(1.15, 1.15), 0.12)
			scale_tween.tween_property(fb, "scale", Vector2(0.8, 0.8), 0.13)
		else:
			if is_instance_valid(scroll):
				scroll.size = target_size
			if is_instance_valid(panel_bg):
				panel_bg.size = bg_target_size
			fb.position = target_pos
			fb.scale = Vector2(0.8, 0.8)





func update_settings() -> void:
	main_view = get_parent().get_parent()
	main_center_container = %MainCenterContainer
	title_anime = %TitleAnime
	h_box_container = $ScrollContainerz/HBoxContainer
	_update_settings_ui()
	_update_fold_layout()
	title_anime.play("loop")




func _update_settings_ui() -> void:
	if is_instance_valid(h_box_container):
		for child in h_box_container.get_children():
			if is_instance_valid(child):
				h_box_container.remove_child(child)
				child.free()

	if not is_instance_valid(main_view):
		return

	var added_setting_names: Dictionary = {}

	# 1. Add settings in the exact saved order of main_view.current_settings
	if not main_view.current_settings.is_empty():
		for custom_setting in main_view.current_settings:
			if custom_setting == null:
				continue
			var setting_name: String = custom_setting.name
			if not ProjectSettings.has_setting(setting_name):
				continue

			added_setting_names[setting_name] = true
			var prop = {
				"name": setting_name,
				"type": custom_setting.type,
				"hint": custom_setting.hint,
				"hint_string": custom_setting.hint_string
			}
			var setting_value = ProjectSettings.get_setting(setting_name)

			match custom_setting.type:
				TYPE_BOOL:
					_add_bool_option(setting_name)
				TYPE_INT:
					_add_int_option(setting_name)
				TYPE_FLOAT:
					_add_float_option(setting_name)
				TYPE_STRING:
					_add_string_option(setting_name, prop)
				TYPE_PACKED_STRING_ARRAY, TYPE_ARRAY:
					var arr_val = setting_value if (setting_value is Array or setting_value is PackedStringArray) else []
					_add_array_button(setting_name, arr_val)
				_:
					_add_string_option(setting_name, prop)

	# 2. Add any remaining Game/Debug/ ProjectSettings not listed in current_settings
	for prop in ProjectSettings.get_property_list():
		var setting_name: String = prop.name
		if not setting_name.begins_with("Game/Debug/"):
			continue
		if added_setting_names.has(setting_name):
			continue

		added_setting_names[setting_name] = true
		var setting_value = ProjectSettings.get_setting(setting_name)
		match prop.type:
			TYPE_BOOL:
				_add_bool_option(setting_name)
			TYPE_INT:
				_add_int_option(setting_name)
			TYPE_FLOAT:
				_add_float_option(setting_name)
			TYPE_STRING:
				_add_string_option(setting_name, prop)
			TYPE_PACKED_STRING_ARRAY, TYPE_ARRAY:
				var arr_val = setting_value if (setting_value is Array or setting_value is PackedStringArray) else []
				_add_array_button(setting_name, arr_val)
			_:
				_add_string_option(setting_name, prop)





var active_drag_node: Control = null
var active_drag_preview: Control = null
var active_drag_from_index: int = -1


static var bool_normal_style: StyleBoxFlat = null
static var bool_hover_style: StyleBoxFlat = null
static var bool_pressed_style: StyleBoxFlat = null


func setup_unified_button_styles() -> void:
	if bool_normal_style != null:
		return

	bool_normal_style = StyleBoxFlat.new()
	bool_normal_style.bg_color = Color(0.301108, 0.309076, 0.76387, 1.0)
	bool_normal_style.border_width_left = 2
	bool_normal_style.border_width_top = 2
	bool_normal_style.border_width_right = 2
	bool_normal_style.border_width_bottom = 2
	bool_normal_style.border_color = Color(0.65, 0.45, 0.95, 0.8)
	bool_normal_style.corner_radius_top_left = 4
	bool_normal_style.corner_radius_top_right = 4
	bool_normal_style.corner_radius_bottom_right = 4
	bool_normal_style.corner_radius_bottom_left = 4

	bool_hover_style = StyleBoxFlat.new()
	bool_hover_style.bg_color = Color(0.310647, 0.380813, 0.790575, 1.0)
	bool_hover_style.border_width_left = 2
	bool_hover_style.border_width_top = 2
	bool_hover_style.border_width_right = 2
	bool_hover_style.border_width_bottom = 2
	bool_hover_style.border_color = Color(0.85, 0.65, 1.0, 1.0)
	bool_hover_style.corner_radius_top_left = 4
	bool_hover_style.corner_radius_top_right = 4
	bool_hover_style.corner_radius_bottom_right = 4
	bool_hover_style.corner_radius_bottom_left = 4

	bool_pressed_style = StyleBoxFlat.new()
	bool_pressed_style.bg_color = Color(0.261878, 0.0506552, 0.501052, 1.0)
	bool_pressed_style.border_width_left = 2
	bool_pressed_style.border_width_top = 2
	bool_pressed_style.border_width_right = 2
	bool_pressed_style.border_width_bottom = 2
	bool_pressed_style.border_color = Color(0.85, 0.65, 1.0, 1.0)
	bool_pressed_style.corner_radius_top_left = 4
	bool_pressed_style.corner_radius_top_right = 4
	bool_pressed_style.corner_radius_bottom_right = 4
	bool_pressed_style.corner_radius_bottom_left = 4


func apply_unified_button_style(btn: Control) -> void:
	if not is_instance_valid(btn):
		return
	setup_unified_button_styles()
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.add_theme_stylebox_override("normal", bool_normal_style)
	btn.add_theme_stylebox_override("hover", bool_hover_style)
	btn.add_theme_stylebox_override("pressed", bool_pressed_style)


func _add_drag_handle_to_option(option: Control) -> void:
	if not is_instance_valid(option):
		return

	var handle = option.get_node_or_null("DragHandle") as Button
	if handle == null:
		handle = Button.new()
		handle.name = "DragHandle"
		handle.text = "≡"
		handle.custom_minimum_size = Vector2(24, 24)
		handle.tooltip_text = "Hold Right Click to Drag & Reorder"
		handle.focus_mode = Control.FOCUS_NONE
		option.add_child(handle)
		option.move_child(handle, 0)

	apply_unified_button_style(handle)

	var setting_btn = option.get_node_or_null("CheckButton")
	if setting_btn == null: setting_btn = option.get_node_or_null("IntString")
	if setting_btn == null: setting_btn = option.get_node_or_null("OptionLabel")
	if setting_btn == null: setting_btn = option.get_node_or_null("Label")
	if setting_btn == null: setting_btn = option.get_node_or_null("Button")

	if is_instance_valid(setting_btn):
		apply_unified_button_style(setting_btn)

	if option.has_method("add_delete_button"):
		option.add_delete_button()

	_connect_drag(option)


func _connect_drag(option: Control) -> void:
	if not option.gui_input.is_connected(_on_option_gui_input.bind(option)):
		option.gui_input.connect(_on_option_gui_input.bind(option))
	var handle = option.get_node_or_null("DragHandle") as Control
	if is_instance_valid(handle) and not handle.gui_input.is_connected(_on_option_gui_input.bind(option)):
		handle.gui_input.connect(_on_option_gui_input.bind(option))




func _on_option_gui_input(event: InputEvent, option: Control) -> void:
	if not is_instance_valid(option):
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				active_drag_node = option
				active_drag_from_index = option.get_index()
				_start_drag_preview(option, event.global_position)
			else:
				if active_drag_node != null:
					_finish_drag_drop(event.global_position)

	elif event is InputEventMouseMotion and active_drag_node != null:
		_update_drag_preview(event.global_position)


func get_option_display_name(option: Control) -> String:
	if not is_instance_valid(option):
		return "Setting"

	var cb = option.get_node_or_null("CheckButton") as CheckButton
	if is_instance_valid(cb) and cb.text != "":
		return cb.text

	var int_lbl = option.get_node_or_null("IntString") as Button
	if is_instance_valid(int_lbl) and int_lbl.text != "":
		return int_lbl.text

	var opt_lbl = option.get_node_or_null("OptionLabel") as Button
	if is_instance_valid(opt_lbl) and opt_lbl.text != "":
		return opt_lbl.text

	var txt_lbl = option.get_node_or_null("Label")
	if is_instance_valid(txt_lbl) and "text" in txt_lbl and txt_lbl.text != "":
		return txt_lbl.text


	var btn = option.get_node_or_null("Button") as Button
	if is_instance_valid(btn) and btn.text != "":
		return btn.text

	return option.name


func _start_drag_preview(option: Control, pos: Vector2) -> void:
	_remove_drag_preview()
	var preview_panel = PanelContainer.new()
	preview_panel.z_index = 120
	preview_panel.z_as_relative = false
	preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.12, 0.35, 0.92)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.65, 0.45, 0.95, 1.0)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	preview_panel.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	var setting_title = get_option_display_name(option)
	label.text = " ≡  " + setting_title + " "
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	preview_panel.add_child(label)

	add_child(preview_panel)
	active_drag_preview = preview_panel
	active_drag_preview.global_position = pos + Vector2(10, 10)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_WM_MOUSE_EXIT:
		_finish_drag_drop(Vector2.ZERO)


func _update_drag_preview(pos: Vector2) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_finish_drag_drop(pos)
		return

	if is_instance_valid(active_drag_preview):
		active_drag_preview.global_position = pos + Vector2(10, 10)

	if not is_instance_valid(active_drag_node):
		return


	var children = h_box_container.get_children()
	if children.size() <= 1:
		return

	var current_idx = active_drag_node.get_index()
	var target_index: int = current_idx
	for i in range(children.size()):
		var child = children[i] as Control
		if not is_instance_valid(child) or child == active_drag_node:
			continue
		var child_rect = child.get_global_rect()
		if pos.y >= child_rect.position.y and pos.y <= child_rect.position.y + child_rect.size.y:
			target_index = i
			break

	if target_index != current_idx:
		h_box_container.move_child(active_drag_node, target_index)



func _remove_drag_preview() -> void:
	if is_instance_valid(active_drag_preview):
		active_drag_preview.queue_free()
		active_drag_preview = null


func _finish_drag_drop(_drop_pos: Vector2) -> void:
	_remove_drag_preview()
	if active_drag_node == null or active_drag_from_index == -1:
		active_drag_node = null
		active_drag_from_index = -1
		return

	var final_index = active_drag_node.get_index()
	if final_index != active_drag_from_index:
		if is_instance_valid(main_view) and main_view.has_method("reorder_settings"):
			main_view.reorder_settings(active_drag_from_index, final_index)

	active_drag_node = null
	active_drag_from_index = -1


func _add_bool_option(setting_name: String) -> void:
	var option = CHECK_BUTTON_OPTION.instantiate() as Control
	option.z_index = 60
	option.z_as_relative = false
	h_box_container.add_child(option)
	if "main_view" in option:
		option.main_view = main_view
	var check_button: CheckButton = option.get_node("CheckButton")
	check_button.z_index = 65
	check_button.z_as_relative = false
	check_button.text = setting_name.get_file()
	check_button.button_pressed = ProjectSettings.get_setting(setting_name)
	_add_drag_handle_to_option(option)


func _add_int_option(setting_name: String, min_value: int = 0, max_value: int = 9999) -> void:
	var option = INT_BUTTON_OPTION.instantiate() as GameDebuggerOption
	option.z_index = 60
	option.z_as_relative = false
	h_box_container.add_child(option)
	option.main_view = main_view
	var spin_box: SpinBox = option.get_node("SpinBox")
	option.get_node("IntString").text = setting_name.get_file()
	spin_box.min_value = min_value
	spin_box.max_value = max_value
	spin_box.step = 1
	spin_box.value = int(ProjectSettings.get_setting(setting_name))
	_add_drag_handle_to_option(option)


func _add_float_option(setting_name: String, min_value: float = -9999.0, max_value: float = 9999.0, step: float = 0.01) -> void:
	var option = INT_BUTTON_OPTION.instantiate() as GameDebuggerOption
	option.z_index = 60
	option.z_as_relative = false
	h_box_container.add_child(option)
	option.main_view = main_view
	var spin_box: SpinBox = option.get_node("SpinBox")
	option.get_node("IntString").text = setting_name.get_file()
	spin_box.min_value = min_value
	spin_box.max_value = max_value
	spin_box.step = step
	spin_box.value = float(ProjectSettings.get_setting(setting_name))
	_add_drag_handle_to_option(option)


func _add_string_option(setting_name: String, prop: Dictionary) -> void:
	var hint_items: Array = []

	var extract_items = func(hs):
		if hs is String and hs != "":
			for s in hs.split(","):
				var item = s.strip_edges()
				if item != "" and not hint_items.has(item):
					hint_items.append(item)
		elif hs is Array or hs is PackedStringArray:
			for s in hs:
				var item = str(s).strip_edges()
				if item != "" and not hint_items.has(item):
					hint_items.append(item)

	if prop != null and "hint_string" in prop:
		extract_items.call(prop["hint_string"])

	if hint_items.is_empty() and is_instance_valid(main_view):
		for cs in main_view.current_settings:
			if cs and cs.name == setting_name and cs.hint_string.size() > 0:
				extract_items.call(cs.hint_string)
				break

	var option: Control = null
	if hint_items.size() > 0:
		option = HINT_ENUM_OPTION.instantiate() as Control
		option.z_index = 60
		option.z_as_relative = false
		h_box_container.add_child(option)
		if "main_view" in option:
			option.main_view = main_view

		var option_button: OptionButton = option.get_node_or_null("OptionButton")
		var option_label: Button = option.get_node_or_null("OptionLabel")
		if option_label:
			option_label.text = setting_name.get_file()

		if option_button:
			option_button.clear()
			for i in range(hint_items.size()):
				option_button.add_item(hint_items[i], i)

			var current_value = str(ProjectSettings.get_setting(setting_name))
			var idx = hint_items.find(current_value)
			if idx == -1:
				idx = 0
				ProjectSettings.set_setting(setting_name, hint_items[0])
				ProjectSettings.save()
			option_button.select(idx)

			if not option_button.item_selected.is_connected(_on_enum_option_selected.bind(setting_name, hint_items)):
				option_button.item_selected.connect(_on_enum_option_selected.bind(setting_name, hint_items))
	else:
		option = TEXT_INPUT_OPTION.instantiate() as Control
		option.z_index = 60
		option.z_as_relative = false
		h_box_container.add_child(option)
		if "main_view" in option:
			option.main_view = main_view
		var label = option.get_node_or_null("Label")
		if label:
			label.text = setting_name.get_file()
		var line_edit: LineEdit = option.get_node_or_null("TextInput") as LineEdit
		if line_edit:
			line_edit.text = str(ProjectSettings.get_setting(setting_name))
			if not line_edit.text_changed.is_connected(_on_string_input_changed.bind(setting_name)):
				line_edit.text_changed.connect(_on_string_input_changed.bind(setting_name))

	if is_instance_valid(option):
		_add_drag_handle_to_option(option)


func _on_enum_option_selected(index: int, setting_name: String, hint_items: Array) -> void:
	if index >= 0 and index < hint_items.size():
		var selected_val = hint_items[index]
		ProjectSettings.set_setting(setting_name, selected_val)
		ProjectSettings.save()
		if is_instance_valid(main_view) and main_view.has_method("save_overwrite_setting"):
			main_view.save_overwrite_setting(setting_name, selected_val)


func _on_string_input_changed(new_text: String, setting_name: String) -> void:
	ProjectSettings.set_setting(setting_name, new_text)
	ProjectSettings.save()
	if is_instance_valid(main_view) and main_view.has_method("save_overwrite_setting"):
		main_view.save_overwrite_setting(setting_name, new_text)



func _add_array_button(setting_name: String, setting_value: Array) -> void:
	if ARRAY_BUTTON_OPTION == null:
		return

	var array_button_instance = ARRAY_BUTTON_OPTION.instantiate() as Control
	if array_button_instance == null:
		return

	array_button_instance.z_index = 60
	array_button_instance.z_as_relative = false
	h_box_container.add_child(array_button_instance)

	if "main_view" in array_button_instance:
		array_button_instance.main_view = main_view

	array_button_instance.setup(setting_name.get_file(), setting_value)
	_add_drag_handle_to_option(array_button_instance)







#func _on_checkbutton_toggled(pressed: bool, check_button, setting_name: String) -> void:
	##check_button.pressed = pressed
	#ProjectSettings.set_setting(setting_name, pressed)
	#ProjectSettings.save()
#
#func _on_optionbutton_selected(index: int, setting_name: String, option_button: OptionButton) -> void:
	#var selected_text = option_button.get_item_text(index)
	#
	#ProjectSettings.set_setting(setting_name, selected_text)
	#ProjectSettings.save()
