@tool
class_name GameDebuggerOption extends HBoxContainer

var sufix:String = "Game/Debug/"
var button: Control:
	get:
		var btn = get_node_or_null("CheckButton")
		if btn == null: btn = get_node_or_null("IntString")
		if btn == null: btn = get_node_or_null("OptionLabel")
		if btn == null: btn = get_node_or_null("Label")
		if btn == null: btn = get_node_or_null("Button")
		if btn == null:
			for c in get_children():
				if is_instance_valid(c) and c.name != "DragHandle" and c.name != "delete_button" and c is Control:
					return c as Control
		return btn as Control

@export_enum("existing", "new") var panel_type: String = "existing"



@export var button_text: String = "Option":
	set(value):
		button_text = value
		if is_instance_valid(button):
			button.text = value

		name = value
		if get_child_count() > 1:
			var extra_child = get_child(1)
			if !is_instance_valid(extra_child) or extra_child.name == "delete_button" \
				and not extra_child.is_in_group("delete_group") \
				and not (extra_child is SpinBox or extra_child is LineEdit):return
			extra_child.name = value
			extra_child.text = value


func _ready() -> void:
	if is_instance_valid(button):
		button.text = button_text
	name = button_text



const DELETE_BUTTON = preload("res://addons/game_debugger/GameDebuggerOptions/delete_button.tscn")

func add_delete_button():
	if not has_node("DeleteButton") and not has_node("delete_button"):
		var instance = DELETE_BUTTON.instantiate()
		add_child(instance)

