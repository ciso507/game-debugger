@tool
extends GameDebuggerOption


var spin_box
var option_button
var main_view:MainView

func get_spin_box() -> SpinBox:
	if is_instance_valid(spin_box):
		return spin_box
	spin_box = get_node_or_null("SpinBox") as SpinBox
	if spin_box == null:
		for child in get_children():
			if child is SpinBox:
				spin_box = child as SpinBox
				break
	return spin_box


func _ready() -> void:
	super()
	if panel_type == "existing":
		add_delete_button()
	var sb = get_spin_box()
	if is_instance_valid(sb) and not sb.value_changed.is_connected(_on_spinbox_value_changed):
		sb.value_changed.connect(_on_spinbox_value_changed)



func get_setting_name_text() -> String:
	var btn = get_node_or_null("IntString") as Button
	if is_instance_valid(btn) and btn.text != "" and btn.text != "≡":
		return btn.text
	return button_text


func get_main_view_node() -> Node:
	if is_instance_valid(main_view):
		return main_view
	if is_inside_tree():
		var list = get_tree().get_nodes_in_group("main_view")
		if list.size() > 0:
			return list[0]
	return null


func _on_spinbox_value_changed(new_value):
	if panel_type != "existing":
		return

	var name_text = get_setting_name_text()
	if name_text == "" or name_text == "≡":
		return

	var key = sufix + name_text
	var curr_val = ProjectSettings.get_setting(key)
	var final_val = new_value
	if typeof(curr_val) == TYPE_INT:
		final_val = int(new_value)
	elif typeof(curr_val) == TYPE_FLOAT:
		final_val = float(new_value)

	ProjectSettings.set_setting(key, final_val)
	ProjectSettings.save()

	var mv = get_main_view_node()
	if is_instance_valid(mv) and mv.has_method("save_overwrite_setting"):
		mv.save_overwrite_setting(key, final_val)








