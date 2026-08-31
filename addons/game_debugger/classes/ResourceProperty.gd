@tool
extends Node
class_name ResProperty

var TYPE_NAMES:Dictionary = {
	TYPE_NIL: "Nil",
	TYPE_BOOL: "Bool",
	TYPE_INT: "Int",
	TYPE_FLOAT: "Float",
	TYPE_STRING: "String",
	TYPE_VECTOR2: "Vector2",
	TYPE_VECTOR3: "Vector3",
	TYPE_COLOR: "Color",
	TYPE_NODE_PATH: "NodePath",
	TYPE_OBJECT: "Object",
	TYPE_DICTIONARY: "Dictionary",
	TYPE_ARRAY: "Array",
	TYPE_PACKED_STRING_ARRAY: "PackedStringArray"
}

var USAGE: Dictionary = {
	PROPERTY_USAGE_DEFAULT: "Default",
	PROPERTY_USAGE_EDITOR: "Editor",
	PROPERTY_USAGE_STORAGE: "Storage",
	PROPERTY_USAGE_NO_INSTANCE_STATE: "No Instance State",
	PROPERTY_USAGE_RESTART_IF_CHANGED: "Restart If Changed",
	PROPERTY_USAGE_SCRIPT_VARIABLE: "Script Variable",
	PROPERTY_USAGE_GROUP: "Group",
	PROPERTY_USAGE_CATEGORY: "Category",
	PROPERTY_USAGE_READ_ONLY: "Read Only",
	PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED: "Update All If Modified"
}



## Property Hints (How properties are displayed in the inspector)
var HINTS: Dictionary = {
	PROPERTY_HINT_NONE: "None",
	PROPERTY_HINT_RANGE: "Range",
	PROPERTY_HINT_ENUM: "Enum",
	PROPERTY_HINT_ENUM_SUGGESTION: "Enum Suggestion",
	PROPERTY_HINT_FILE: "File",
	PROPERTY_HINT_DIR: "Directory",
	PROPERTY_HINT_RESOURCE_TYPE: "Resource Type",
	PROPERTY_HINT_MULTILINE_TEXT: "Multiline Text",
	PROPERTY_HINT_OBJECT_ID: "Object ID",
	PROPERTY_HINT_TYPE_STRING: "TypeString",
	PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE: "NodePath to Edited Node",
	PROPERTY_HINT_MAX: "Max"
}

var PRESETS: Dictionary = {
	0: "Custom",
	1: "String",
	2: "Bool",
	3: "Array",
	4: "Int",
	5: "Float",
	6: "Enum"
}


