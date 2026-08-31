@tool
extends Control
class_name DeleteButton

@onready var button: Button = $Button
@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	if is_instance_valid(button) and not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)
	if is_instance_valid(button) and not button.mouse_entered.is_connected(_on_button_mouse_entered):
		button.mouse_entered.connect(_on_button_mouse_entered)
	if is_instance_valid(button) and not button.mouse_exited.is_connected(_on_button_mouse_exited):
		button.mouse_exited.connect(_on_button_mouse_exited)

	var mv = get_main_view()
	if is_instance_valid(mv) and "current_language" in mv:
		apply_language(mv.get("current_language"))
	else:
		apply_language("EN")


func apply_language(lang_code: String) -> void:
	if is_instance_valid(button):
		button.tooltip_text = "Eliminar Configuración" if lang_code == "ES" else "Delete Setting"


func get_main_view() -> Node:
	var parent_option = get_parent()
	if is_instance_valid(parent_option) and "main_view" in parent_option and parent_option.main_view != null:
		return parent_option.main_view
	var mv_list = get_tree().get_nodes_in_group("main_view")
	if mv_list.size() > 0:
		return mv_list[0]
	return null


func get_setting_name_text() -> String:
	var parent_option = get_parent()
	if not is_instance_valid(parent_option):
		return ""

	var cb = parent_option.get_node_or_null("CheckButton") as CheckButton
	if is_instance_valid(cb) and cb.text != "":
		return cb.text

	var int_lbl = parent_option.get_node_or_null("IntString") as Button
	if is_instance_valid(int_lbl) and int_lbl.text != "":
		return int_lbl.text

	var opt_lbl = parent_option.get_node_or_null("OptionLabel") as Button
	if is_instance_valid(opt_lbl) and opt_lbl.text != "":
		return opt_lbl.text

	var txt_lbl = parent_option.get_node_or_null("Label")
	if is_instance_valid(txt_lbl) and "text" in txt_lbl and txt_lbl.text != "":
		return txt_lbl.text

	var btn = parent_option.get_node_or_null("Button") as Button
	if is_instance_valid(btn) and btn.text != "":
		return btn.text

	return parent_option.name


func _on_button_pressed() -> void:
	var name_text = get_setting_name_text()
	if name_text == "":
		get_parent().queue_free()
		return

	var key = "Game/Debug/" + name_text

	if ProjectSettings.has_setting(key):
		ProjectSettings.clear(key)
		ProjectSettings.save()

	var main_view_node = get_main_view()
	if is_instance_valid(main_view_node) and main_view_node.has_method("remove_overwrite_setting"):
		main_view_node.remove_overwrite_setting(key)

	var parent_option = get_parent()
	if is_instance_valid(parent_option):
		parent_option.queue_free()


func _on_button_mouse_entered() -> void:
	if is_instance_valid(texture_rect):
		texture_rect.modulate = Color8(255, 255, 255, 255)


func _on_button_mouse_exited() -> void:
	if is_instance_valid(texture_rect):
		texture_rect.modulate = Color8(255, 255, 255, 73)
