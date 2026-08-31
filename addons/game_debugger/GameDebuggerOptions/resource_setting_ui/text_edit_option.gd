@tool
extends Control




@onready var text_edit: TextEdit = $TextEdit
var array_to_use= []
var current_array_type:String


func _ready() -> void:
	z_index = 80
	z_as_relative = false
	apply_info_panel_theme()
	if is_instance_valid(text_edit):
		text_edit.gui_input.connect(_on_text_input)
	align_to_setting_resource()


func apply_info_panel_theme() -> void:
	var te = get_node_or_null("TextEdit") as TextEdit
	if is_instance_valid(te):
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
		style.content_margin_left = 8
		style.content_margin_top = 8
		style.content_margin_right = 8
		style.content_margin_bottom = 8
		te.add_theme_stylebox_override("normal", style)
		te.add_theme_stylebox_override("focus", style)



func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		align_to_setting_resource()


func align_to_setting_resource() -> void:
	var parent_node = get_parent()
	var sr: Control = null
	if is_instance_valid(parent_node):
		sr = parent_node.get_node_or_null("SettingResource") as Control
	if is_instance_valid(sr):
		var sr_rect = sr.get_global_rect()
		global_position = Vector2(sr_rect.position.x + sr_rect.size.x + 10.0, sr_rect.position.y)



func _on_text_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var text: String = text_edit.text

		# Store caret line/column
		var caret_line = text_edit.get_caret_line()
		var caret_column = text_edit.get_caret_column()

		var cleaned_lines := []
		var array_words := []

		for line in text.split("\n", false):
			var new_line_words := []
			var words = line.split(" ", false)
			for word in words:
				if word.strip_edges() == "":
					continue

				var cleaned_word := ""
				for c in word:
					if is_letter_or_digit(c) or c == "_":
						cleaned_word += c

				if cleaned_word != "":
					new_line_words.append(cleaned_word)
					array_words.append(cleaned_word)

			cleaned_lines.append(" ".join(new_line_words))

		# Update TextEdit
		text_edit.text = "\n".join(cleaned_lines)

		# Restore caret
		text_edit.set_caret_line(caret_line)
		text_edit.set_caret_column(caret_column)

		# Update array_set
		if array_to_use == null:
			array_to_use = []
		array_to_use.clear()
		array_to_use += array_words

		update_hint_string_status()


func update_hint_string_status() -> void:
	if is_instance_valid(get_tree()):
		var hint_nodes = get_tree().get_nodes_in_group("hint_string_option")
		for node in hint_nodes:
			if is_instance_valid(node):
				if array_to_use.size() > 0:
					if node.has_method("set_outline_green"):
						node.set_outline_green()
				else:
					if node.has_method("set_outline_red"):
						node.set_outline_red()



func is_letter_or_digit(char: String) -> bool:
	if char.length() != 1:
		return false
	var code = char.to_utf8_buffer()[0]
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 48 and code <= 57)
