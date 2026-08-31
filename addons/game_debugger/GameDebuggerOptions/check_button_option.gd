@tool
extends GameDebuggerOption


var main_view


func _ready() -> void:
	super()
	if panel_type == "existing":
		add_delete_button()



func get_setting_name_text() -> String:
	var cb = get_node_or_null("CheckButton") as CheckButton
	if is_instance_valid(cb) and cb.text != "" and cb.text != "≡":
		return cb.text
	return button_text


func get_main_view_node() -> Node:
	if is_instance_valid(main_view):
		return main_view
	if is_inside_tree():
		var list = get_tree().get_nodes_in_group("main_view")
		if list.size() > 0:
			return list[0]
	return null


func _on_check_button_toggled(toggled_on: bool) -> void:
	if panel_type != "existing":
		return

	var name_text = get_setting_name_text()
	if name_text == "" or name_text == "≡":
		return

	var key = sufix + name_text
	ProjectSettings.set_setting(key, toggled_on)
	ProjectSettings.save()

	var mv = get_main_view_node()
	if is_instance_valid(mv) and mv.has_method("save_overwrite_setting"):
		mv.save_overwrite_setting(key, toggled_on)


