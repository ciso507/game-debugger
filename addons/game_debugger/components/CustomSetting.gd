@tool
class_name CustomSetting extends Resource

@export_subgroup("info")
# Properties for the setting
@export var name: String = ""
@export var type: Variant.Type = TYPE_NIL
@export var usage: PropertyUsageFlags = PROPERTY_USAGE_DEFAULT
@export var hint: PropertyHint = PROPERTY_HINT_NONE
@export var hint_string: Array[String] = []

@export var default_value: String = ""  # can hold string or bool
@export var bool_value:bool  = false
@export var int_value:int  = 0
@export var float_value:float  = 0.0
@export var array_value: PackedStringArray


func _enter_tree() -> void:
	update_default_value()

func update_default_value():
	if hint_string.size() > 0:
		# If hint_string exists, pick the first element if default_value is empty
		if default_value == "" or default_value == null:
			default_value = hint_string[0]
	else:
		default_value = "false"
	notify_property_list_changed()  # refresh Inspector
