@tool
class_name ProjSettings extends Node

@export var settings_res: Array[CustomSetting]
@export var resource_created: Array[CustomSetting]
var main_view: MainView


func _set_up_settings() -> void:
	update_settings()


func update_settings():
	main_view = get_owner()
	var settings_resources = main_view.load_resources_from_user() if is_instance_valid(main_view) else []
	var has_changes: bool = false
	
	# Register settings
	for s in settings_resources:
		if s == null or s.name == "" or s.name.ends_with("/"): # skip invalid names
			continue
		s.update_default_value()
		if add_project_setting(s.name, s):
			has_changes = true

	if has_changes:
		ProjectSettings.save()


func add_project_setting(setting_name: String, setting_) -> bool:
	var current_value
	var hint_str: String = ""
	var is_new: bool = false

	# --- Get or set default value ---
	if ProjectSettings.has_setting(setting_name):
		current_value = ProjectSettings.get_setting(setting_name)
	else:
		match setting_.type:
			TYPE_BOOL:
				current_value = setting_.bool_value
			TYPE_PACKED_STRING_ARRAY:
				current_value = setting_.array_value.duplicate()
			_:
				current_value = setting_.default_value

		ProjectSettings.set_setting(setting_name, current_value)
		ProjectSettings.set_initial_value(setting_name, current_value)
		is_new = true

	# --- Hint string handling ---
	if setting_.type == TYPE_PACKED_STRING_ARRAY:
		hint_str = ""  # force empty
	elif setting_.hint_string.size() > 0:
		hint_str = ",".join(setting_.hint_string)

	# --- Register in editor ---
	var property_info = {
		"name": setting_name,
		"type": setting_.type,
		"usage": setting_.usage,
		"hint": setting_.hint,
		"hint_string": hint_str,
		"default_value": current_value
	}

	ProjectSettings.add_property_info(property_info)
	return is_new
