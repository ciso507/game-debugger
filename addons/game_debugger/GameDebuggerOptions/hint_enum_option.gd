@tool
extends GameDebuggerOption



enum TYPE { NONE, TYPE, USAGE, HINT, PRESET }
@export var genre: TYPE = TYPE.NONE


@export var items:Array = []
var game_debugger_singleton
var main_view:MainView
var owner_setting

var res_prop:ResProperty

var parent_setting_resource
var option_button: OptionButton




func _enter_tree() -> void:
	parent_setting_resource = get_parent().get_parent() if get_parent() else null

	if genre != TYPE.NONE:
		owner_setting = parent_setting_resource
		if owner_setting != null and "res_prop" in owner_setting and owner_setting.get("res_prop") != null:
			res_prop = owner_setting.get("res_prop")
		else:
			res_prop = ResProperty.new()

	match_genre()

	option_button = get_child(1) as OptionButton if get_child_count() > 1 else null
	if option_button != null and not option_button.item_selected.is_connected(_on_option_button_item_selected):
		option_button.item_selected.connect(_on_option_button_item_selected)


func _ready() -> void:
	super()
	if res_prop == null:
		if owner_setting != null and "res_prop" in owner_setting and owner_setting.get("res_prop") != null:
			res_prop = owner_setting.get("res_prop")
		else:
			res_prop = ResProperty.new()

	match_genre()

	if panel_type == "existing":
		add_delete_button()



func match_genre() -> void:
	option_button = get_child(1) as OptionButton if get_child_count() > 1 else null
	if option_button == null:
		return

	if res_prop == null:
		res_prop = ResProperty.new()

	option_button.clear()

	match genre:
		TYPE.TYPE:
			add_items_from_dict(res_prop.TYPE_NAMES)
		TYPE.USAGE:
			add_items_from_dict(res_prop.USAGE)
		TYPE.HINT:
			add_items_from_dict(res_prop.HINTS)
		TYPE.PRESET:
			add_items_from_dict(res_prop.PRESETS)
		_:
			pass



func add_items_from_dict(dict: Dictionary) -> void:
	if dict.size() > 0:
		var option_button: OptionButton = get_child(1) as OptionButton
		if option_button == null:
			return
		option_button.clear()
		for key in dict.keys():
			var item_title = str(dict[key])
			var item_id = int(key) if str(key).is_valid_int() else -1
			option_button.add_item(item_title, item_id)

			




func _get_setting_resource_owner() -> Node:
	if is_instance_valid(owner_setting) and owner_setting.has_method("apply_preset"):
		return owner_setting
	var curr: Node = get_parent()
	while is_instance_valid(curr):
		if curr.has_method("apply_preset"):
			return curr
		curr = curr.get_parent()
	return null


func get_option_button() -> OptionButton:
	var ob = get_node_or_null("OptionButton") as OptionButton
	if ob == null:
		for c in get_children():
			if c is OptionButton:
				return c as OptionButton
	return ob


func get_setting_name_text() -> String:
	var btn = get_node_or_null("OptionLabel") as Button
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


func _on_option_button_item_selected(index: int) -> void:
	var ob = get_option_button()
	if not is_instance_valid(ob):
		return
	var text: String = ob.get_item_text(index)

	if genre != TYPE.NONE:
		var sr_owner = _get_setting_resource_owner()
		if sr_owner != null:
			if genre == TYPE.PRESET:
				sr_owner.apply_preset(text)
			else:
				sr_owner._update_current_values(text, genre)
	else:
		if panel_type != "existing":
			return
		var name_text = get_setting_name_text()
		if name_text == "" or name_text == "≡":
			return
		var key = sufix + name_text
		ProjectSettings.set_setting(key, text)
		ProjectSettings.save()

		var mv = get_main_view_node()
		if is_instance_valid(mv) and mv.has_method("save_overwrite_setting"):
			mv.save_overwrite_setting(key, text)




