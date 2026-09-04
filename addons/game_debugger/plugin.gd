@tool
extends EditorPlugin
class_name GameDebbuggerPlugin

const PLUGIN_NAME :String= "GameDebugger"

const Mainview = preload("res://addons/game_debugger/components/main_view.tscn")
#const MainPanelScene = preload("res://addons/game_debugger/components/main_panel.tscn")

var main_screen_button: Button
var main_panel: Control
var main_view:Control
static var main_view_instance: Node



func _enable_plugin() -> void:
	pass


func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir()



func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_load_main_view()


func _load_main_view() -> void:
	if is_instance_valid(main_view):
		main_view.queue_free()
		main_view = null

	var scene_res = load("res://addons/game_debugger/components/main_view.tscn") as PackedScene
	if scene_res:
		main_view = scene_res.instantiate()
		main_view.hide()
		call_deferred("_add_main_view_to_editor")


func reload_plugin() -> void:
	var interface = get_editor_interface()
	if is_instance_valid(interface):
		interface.set_plugin_enabled("game_debugger", false)
		interface.set_plugin_enabled("game_debugger", true)
		call_deferred("_focus_main_screen")


func _add_main_view_to_editor() -> void:
	var editor_screen = get_editor_interface().get_editor_main_screen()
	if is_instance_valid(editor_screen) and is_instance_valid(main_view):
		if main_view.get_parent() != editor_screen:
			editor_screen.add_child(main_view)
		call_deferred("_focus_main_screen")


func _focus_main_screen() -> void:
	var interface = get_editor_interface()
	if is_instance_valid(interface) and interface.has_method("set_main_screen_editor"):
		interface.set_main_screen_editor(PLUGIN_NAME)


func _exit_tree() -> void:
	if is_instance_valid(main_view):
		main_view.queue_free()
		main_view = null


func _disable_plugin() -> void:
	if is_instance_valid(main_view):
		main_view.queue_free()
		main_view = null


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return PLUGIN_NAME


func _get_plugin_icon() -> Texture2D:
	return load("res://addons/game_debugger/assets/icon.svg")


func _make_visible(visible: bool) -> void:
	if not is_instance_valid(main_view) or not main_view.has_method("update_plugin"):
		_load_main_view()

	if is_instance_valid(main_view):
		main_view.visible = visible
		if visible and main_view.has_method("update_plugin"):
			main_view.update_plugin()


