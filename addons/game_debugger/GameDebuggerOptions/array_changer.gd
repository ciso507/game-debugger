@tool
extends Control



@onready var text_edit: TextEdit = $TextEdit
@onready var update_button: Button = $UpdateButton

var main_view:MainView
var array_setup: Array = []
var last_matches :Array= []  # store matches from autocomplete
var nodes

func _enter_tree() -> void:
	#if is_instance_valid(get_tree()):
		#nodes = get_tree().get_nodes_in_group("main_view")
		#call_deferred("_safe_assign_main_view")
	
	#main_view = get_tree().get_nodes_in_group("main_view")[0]
	text_edit = $TextEdit
	update_button = $UpdateButton
	set_process(true)
	if text_edit:
		if not text_edit.text_changed.is_connected(_on_text_changed):
			text_edit.text_changed.connect(_on_text_changed)

		# Example for TextEdit gui_input
		if not text_edit.gui_input.is_connected(_on_text_edit_input):
			text_edit.gui_input.connect(_on_text_edit_input)

	# Example for Button pressed
	if not update_button.pressed.is_connected(update_info):
		update_button.pressed.connect(update_info)



func _safe_assign_main_view() -> void:
	if nodes.size() > 0:
		main_view = nodes[0]
		pass # print(main_view, "karrer the main")
	else:
		push_warning("No node in group 'main_view' found")




func _on_text_edit_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		apply_autocomplete_match()



func update_info():
	update_setting(setting_name)


func _on_text_changed() -> void:
	var new_text := text_edit.text
	_update_array_from_text(new_text)

	# Example: call autocomplete with your card dictionary
	update_autocomplete_matches(main_view.card_pool)



func _update_array_from_text(new_text) -> void:
	var parts = new_text.split(",", false)
	var temp_array := []

	for part in parts:
		var sub_parts = part.strip_edges().split(" ")
		for word in sub_parts:
			if word.strip_edges() == "":
				continue
			var cleaned = ""
			for c in word:
				if is_letter_or_digit(c) or c == "_":
					cleaned += c
			if cleaned != "":
				temp_array.append(cleaned)
	array_setup = temp_array


func is_letter_or_digit(char: String) -> bool:
	if char.length() != 1:
		return false
	var code = char.unicode_at(0)
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 48 and code <= 57)  # A-Z, a-z, 0-9







func get_clean_words(text: String) -> Array[String]:
	var words: Array[String] = []
	var parts = text.split(",") # split by commas -> "bat, car, rat"

	for p in parts:
		var w = p.strip_edges() # remove spaces
		var valid := true

		# check each character of the word
		for c in w:
			if not c.is_letter(): # here is_letter() works because c is a Char
				valid = false
				break

		if valid and w != "":
			words.append(w)

	return words





func is_letter(char: String) -> bool:
	if char.length() != 1:
		return false
	var code = char.unicode_at(0)
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122) # A-Z or a-z   allow for numbers too.. .fix it





	# Local function to check separators
func is_separator(c: String) -> bool:
	return c == " " or c == "," or c == "\t"
	

var sufix:String = "Game/Debug/"
var setting_name

func update_setting(_setting_name: String, _array_setup: Array = []) -> void:
	setting_name = _setting_name

	var text_to_process: String = ""

	if _array_setup.size() > 0:
		# Convert all items to String before joining
		var safe_array: Array = []
		for item in _array_setup:
			safe_array.append(str(item))
		text_to_process = "\n".join(safe_array)
	else:
		if text_edit and text_edit is TextEdit:
			text_to_process = text_edit.text
		else:
			text_to_process = ""


	# Normalize whitespace
	text_to_process = text_to_process.replace("\t", " ").replace("\n", " ")

	var final_words: Array[String] = []

	# Split by spaces and commas, strip each word
	for part in text_to_process.split(" ", false):
		for sub_part in part.split(",", false):
			var w = sub_part.strip_edges()
			if w != "":
				final_words.append(w)

		
	if not text_edit or not is_instance_valid(text_edit):
		var parent = get_parent()
		if parent:
			text_edit = parent.get_node_or_null("TextEditOption")



	if is_instance_valid(text_edit):
		text_edit.text = "\n".join(final_words)
	else:
		pass
#		print("Warning: TextEditOption not found in parent!")

	# Update array and ProjectSettings
	array_setup = final_words
	var key = sufix + setting_name
	ProjectSettings.set_setting(key, array_setup)
	ProjectSettings.save()
	if is_instance_valid(main_view):
		main_view.save_overwrite_setting(key, array_setup)






#region AutoCompletion Code


@onready var popup_menu: PopupMenu = $PopupMenu


func apply_autocomplete_match() -> void:
	if last_matches.size() == 0 or text_edit == null:
		return

	var match_word = last_matches[0]  # first match
	var line_idx = text_edit.get_caret_line()
	var col_idx = text_edit.get_caret_column()
	var line_text = text_edit.get_line(line_idx)

	# Find the word under the caret
	var start_idx = col_idx
	var end_idx = col_idx
	while start_idx > 0 and not is_separator(line_text[start_idx - 1]):
		start_idx -= 1
	while end_idx < line_text.length() and not is_separator(line_text[end_idx]):
		end_idx += 1

	# Replace only the current word with the autocompleted word
	var new_line = line_text.substr(0, start_idx) + match_word + line_text.substr(end_idx, line_text.length() - end_idx)
	text_edit.set_line(line_idx, new_line)

	# Move caret after the autocompleted word
	text_edit.set_caret_line(line_idx)
	text_edit.set_caret_column(start_idx + match_word.length())




func update_autocomplete_matches(dict_to_search: Dictionary) -> void:
	if text_edit == null or panel_menu == null:
		return

	var line_idx = text_edit.get_caret_line()
	var col_idx = text_edit.get_caret_column()
	var line_text = text_edit.get_line(line_idx)
	if line_text == "":
		last_matches = []
		panel_menu.hide()
		return

	# Find start and end of word under caret
	var start_idx = col_idx
	var end_idx = col_idx

	while start_idx > 0 and not is_separator(line_text[start_idx - 1]):
		start_idx -= 1
	while end_idx < line_text.length() and not is_separator(line_text[end_idx]):
		end_idx += 1

	var word_under_caret = line_text.substr(start_idx, end_idx - start_idx)
	if word_under_caret == "":
		last_matches = []
		panel_menu.hide()
		return

	# Search for matches
	var lower_input = word_under_caret.to_lower()
	last_matches = []
	for key in dict_to_search.keys():
		if str(key).to_lower().find(lower_input) != -1:
			last_matches.append(str(key))

	if last_matches.size() > 0:
		_show_autocomplete_popup(last_matches)
#		print("Matches for '", word_under_caret, "' on line ", line_idx, ": ", last_matches)
		text_edit.grab_focus()
	else:
		panel_menu.hide()



@onready var popup_panel: PopupPanel = $PopupPanel
@onready var panel_menu: Control = $PanelMenu
@onready var container: VBoxContainer = $PanelMenu/MarginContainer/Container


func _show_autocomplete_popup(matches: Array) -> void:
	for i in container.get_children():
		i.queue_free()


	for n in matches:
		var btn = Button.new()
		btn.text = n
		btn.z_index = 45
		btn.scale = Vector2(0.8, 0.8)

		# Align text to the left
		btn.alignment = 0  # Godot 4 uses Label constants
		container.add_child(btn)


	# Get caret position relative to the root Control
	var caret_local: Vector2 = text_edit.get_caret_draw_pos()
	var popup_pos: Vector2 = text_edit.get_global_position() + caret_local

	# Position the PopupPanel at the caret
	panel_menu.global_position = popup_pos
	panel_menu.show()

	# Keep typing enabled
	text_edit.grab_focus()


func _on_suggestion_pressed():
	pass
