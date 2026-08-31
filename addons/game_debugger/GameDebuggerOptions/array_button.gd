@tool
extends GameDebuggerOption


const ARRAY_CHANGER = preload("res://addons/game_debugger/GameDebuggerOptions/array_changer.tscn")
@export var but_array:Array = []
var array_changer_instance: Node = null
var setting_name :String = ""
var main_view

func _ready() -> void:
	super()

func setup(_setting_name:String, setting_value:Array):
	
#	_setup_main_view_and_changer()
	
	#main_view = get_parent().get_parent().get_parent().get_parent().get_parent()
	var b:Node = get_node_or_null("Button") 
	setting_name = _setting_name
	
	b.text = _setting_name
	but_array= setting_value
	create_array_changer(false)


#func _setup_main_view_and_changer() -> void:
	#if is_instance_valid(get_tree()):
		#var main_views = get_tree().get_nodes_in_group("main_view")
		#if main_views.size() > 0:
			#main_view = main_views[0]



func _on_button_pressed() -> void:
	var all_array_changers = []


	if is_instance_valid(get_tree()):
		all_array_changers = get_tree().get_nodes_in_group("array_changer")
		array_changer_instance.main_view = get_tree().get_nodes_in_group("main_view")[0]
	# Hide all other changers
	for i in all_array_changers:
		if i != array_changer_instance:
			i.hide()
			i.panel_menu.hide()
	hide_setting_resource_panels()
	
	if is_instance_valid(array_changer_instance):
		if array_changer_instance.visible:
			# Save info before hiding
			but_array = array_changer_instance.array_setup
			array_changer_instance.visible = false
		else:
			# Restore info before showing
			array_changer_instance.update_setting(setting_name, but_array)
			array_changer_instance.visible = true
	else:
		create_array_changer(true)



func hide_setting_resource_panels()->void:
	var all_setting_resource_panels = []
	if is_instance_valid(get_tree()):
		all_setting_resource_panels = get_tree().get_nodes_in_group("setting_resource")

	# Hide all other changers
	for i in all_setting_resource_panels:
		i.hide()
	
	




func create_array_changer(value :bool= false):
	var main_center_container = main_view.main_center_container

	# Only instantiate if not already valid
	if not is_instance_valid(array_changer_instance):
		array_changer_instance = ARRAY_CHANGER.instantiate()
		main_center_container.call_deferred("add_child", array_changer_instance)

	
#	array_changer_instance.main_view = main_view
	if is_instance_valid(array_changer_instance):
		array_changer_instance.main_view = main_view
		array_changer_instance.update_setting(setting_name, but_array)
		array_changer_instance.visible = value



func _exit_tree() -> void:
	if is_instance_valid(array_changer_instance):
		array_changer_instance.queue_free()
		array_changer_instance = null
