@tool
extends GameDebuggerOption

var main_view


func get_line_edit() -> LineEdit:
	var line_edit = get_node_or_null("TextInput") as LineEdit
	if line_edit == null:
		for child in get_children():
			if child is LineEdit:
				line_edit = child as LineEdit
				break
	return line_edit


func _ready() -> void:
	super()
	var text_input = get_line_edit()
	if is_instance_valid(text_input) and not text_input.is_connected("text_changed", Callable(self, "_on_text_input_text_changed")):
		text_input.text_changed.connect(_on_text_input_text_changed)



func _on_text_input_text_changed(new_text: String) -> void:
	var parent_node = get_parent()
	if is_instance_valid(parent_node):
		var grandpa = parent_node.get_parent()
		if is_instance_valid(grandpa) and grandpa.has_method("update_text"):
			grandpa.update_text(new_text)

