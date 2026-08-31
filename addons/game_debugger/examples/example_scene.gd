extends Node2D


## To test this you must add the settings by yourself
const SUFIX_DEBUG: String = "Game/Debug/"
var debug_mode: bool = ProjectSettings.get_setting(SUFIX_DEBUG + "DebugMode", false)
var debug_level_difficulty: String = ProjectSettings.get_setting(SUFIX_DEBUG + "DebugLevelDifficulty", "difficult1")

func _ready() -> void:
	if debug_mode:
		print("ok is debug")
	print(debug_level_difficulty, "..difficulty level")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
