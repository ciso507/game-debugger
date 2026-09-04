@tool
class_name MainView extends Control



@onready var project_settings_debug: ProjSettings = $ProjectSettingsDebug
@onready var main_view_manager: MainViewManager = $MainCenterContainer/MainViewManager
@onready var setting_resource_node: SettingResource = $SettingCreatorContainer/SettingResourceManager/SettingResource

@onready var main_center_container: CenterContainer = %MainCenterContainer


const ContainerCustomSetting = preload("res://addons/game_debugger/resources/ContainerCustomSetting.gd")
@export var save_resource_file: String = "user://custom_settings.tres"
var resources_created


#var combat_card_lib :CardLibrary

var res_prop:ResProperty

@onready var text_edit_main: Control = $SettingCreatorContainer/SettingResourceManager/TextEditOption

@onready var setting_resource: SettingResource = %SettingResource

var card_pool: Dictionary = {
	"combat_attack": "example",
	"combat_defend": "example",
	"combat_grave_assault": "example",
	"combat_backstabb": "example",
	"combat_1day_we_all_die": "example",
	
}




@onready var bg_center_container: Control = get_node_or_null("%BgCenterContainer")
@onready var social_icons_container: Control = %SocialIconsContainer
@onready var margin_container: Control = get_node_or_null("Margin")
@onready var setting_creator_container: Control = %SettingCreatorContainer

var is_panning: bool = false
var pan_offset: Vector2 = Vector2.ZERO
var drag_start_mouse: Vector2 = Vector2.ZERO
var drag_start_offset: Vector2 = Vector2.ZERO

var is_dragging_setting_resource: bool = false
var drag_setting_resource_offset: Vector2 = Vector2.ZERO

var is_dragging_info_panel: bool = false
var drag_info_panel_offset: Vector2 = Vector2.ZERO



func _enter_tree() -> void:
	if not ProjectSettings.settings_changed.is_connected(update_plugin):
		ProjectSettings.settings_changed.connect(update_plugin)
	if not resized.is_connected(_on_main_view_resized):
		resized.connect(_on_main_view_resized)
	update_plugin()


const STEAM_WISHLIST_URL = "https://store.steampowered.com/app/2507500/Bounty_Hunters/"
const GITHUB_DOCS_URL = "https://github.com/ciso507/game-debugger"
const LANG_SETTING_FILE = "user://language_setting.txt"
var current_language: String = "EN"


func save_language_setting(lang: String) -> void:
	var f = FileAccess.open(LANG_SETTING_FILE, FileAccess.WRITE)
	if f:
		f.store_string(lang)


func load_language_setting() -> String:
	if FileAccess.file_exists(LANG_SETTING_FILE):
		var f = FileAccess.open(LANG_SETTING_FILE, FileAccess.READ)
		if f:
			var content = f.get_as_text().strip_edges()
			if content == "ES" or content == "EN":
				return content
	return "EN"


func _on_language_option_button_item_selected(index: int) -> void:
	current_language = "ES" if index == 1 else "EN"
	save_language_setting(current_language)
	apply_language(current_language)


func _on_docs_button_pressed() -> void:
	OS.shell_open(GITHUB_DOCS_URL)


func _ready() -> void:
	if not resized.is_connected(_on_main_view_resized):
		resized.connect(_on_main_view_resized)
	if has_node("%ReloadButton"):
		var reload_btn = get_node("%ReloadButton") as Button
		if is_instance_valid(reload_btn) and not reload_btn.pressed.is_connected(_on_reload_button_pressed):
			reload_btn.pressed.connect(_on_reload_button_pressed)
	if has_node("%InfoButton"):
		var info_btn = get_node("%InfoButton") as Button
		if is_instance_valid(info_btn) and not info_btn.pressed.is_connected(_on_info_button_pressed):
			info_btn.pressed.connect(_on_info_button_pressed)
	if has_node("%UtilityButton"):
		var util_btn = get_node("%UtilityButton") as Button
		if is_instance_valid(util_btn) and not util_btn.pressed.is_connected(_on_utility_button_pressed):
			util_btn.pressed.connect(_on_utility_button_pressed)
	if has_node("%DocsButton"):
		var docs_btn = get_node("%DocsButton") as Button
		if is_instance_valid(docs_btn) and not docs_btn.pressed.is_connected(_on_docs_button_pressed):
			docs_btn.pressed.connect(_on_docs_button_pressed)

	current_language = load_language_setting()
	var lang_opt = get_node_or_null("%LanguageOptionButton") as OptionButton
	if is_instance_valid(lang_opt):
		lang_opt.selected = 1 if current_language == "ES" else 0
		if not lang_opt.item_selected.is_connected(_on_language_option_button_item_selected):
			lang_opt.item_selected.connect(_on_language_option_button_item_selected)

	_setup_banner_cards_wishlist()
	apply_language(current_language)
	call_deferred("_apply_panning_and_clamping")


func _setup_banner_cards_wishlist() -> void:
	var card_nodes = [
		get_node_or_null("MainCenterContainer/PanelContainer/MainImage/HBoxContainer2/TextureRect"),
		get_node_or_null("MainCenterContainer/PanelContainer/MainImage/HBoxContainer2/TextureRect2"),
		get_node_or_null("MainCenterContainer/PanelContainer/MainImage/HBoxContainer2/TextureRect3")
	]
	for card in card_nodes:
		if is_instance_valid(card) and card is Control:
			card.mouse_filter = Control.MOUSE_FILTER_STOP
			card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			if not card.gui_input.is_connected(_on_card_image_gui_input):
				card.gui_input.connect(_on_card_image_gui_input)


func _on_card_image_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		OS.shell_open(STEAM_WISHLIST_URL)
		get_viewport().set_input_as_handled()


func apply_language(lang_code: String) -> void:
	current_language = lang_code
	var is_es = (current_language == "ES")

	# 1. Language selector
	var lang_opt = get_node_or_null("%LanguageOptionButton") as OptionButton
	if is_instance_valid(lang_opt):
		lang_opt.selected = 1 if is_es else 0
		lang_opt.tooltip_text = "Seleccionar Idioma" if is_es else "Select Language"

	var lang_lbl = get_node_or_null("%LanguageLabel") as Label
	if is_instance_valid(lang_lbl):
		lang_lbl.text = "🌐 Idioma:" if is_es else "🌐 Language:"

	# 2. Top Toolbar
	var docs_btn = get_node_or_null("%DocsButton") as Button
	if is_instance_valid(docs_btn):
		docs_btn.text = "Documentación" if is_es else "Docs"
		docs_btn.tooltip_text = "Abrir Documentación" if is_es else "Open Documentation"

	var support_btn = get_node_or_null("%SupportButton") as Button
	if is_instance_valid(support_btn):
		support_btn.text = "Patrocinar" if is_es else "Sponsor"
		support_btn.tooltip_text = "Apoyar Dialogue Manager" if is_es else "Support Dialogue Manager"

	var test_btn = get_node_or_null("%TestLineButton") as Button
	if is_instance_valid(test_btn):
		test_btn.tooltip_text = "Probar diálogo desde la línea actual" if is_es else "Test dialogue from current line"

	# 3. Banner cards wishlist tooltip
	var card_tooltip = "¡Añade Bounty Hunters a tu lista de deseados en Steam!" if is_es else "Wishlist Bounty Hunters on Steam!"
	var card_nodes = [
		get_node_or_null("MainCenterContainer/PanelContainer/MainImage/HBoxContainer2/TextureRect"),
		get_node_or_null("MainCenterContainer/PanelContainer/MainImage/HBoxContainer2/TextureRect2"),
		get_node_or_null("MainCenterContainer/PanelContainer/MainImage/HBoxContainer2/TextureRect3")
	]
	for card in card_nodes:
		if is_instance_valid(card) and card is Control:
			card.tooltip_text = card_tooltip

	# 4. Action buttons
	var new_setting_btn = get_node_or_null("%NewSettingButton") as Button
	if is_instance_valid(new_setting_btn):
		new_setting_btn.text = "Crear Nueva\nConfiguración..." if is_es else "Create New Setting..."

	var reload_btn = get_node_or_null("%ReloadButton") as Button
	if is_instance_valid(reload_btn):
		reload_btn.text = "Recargar\nAddon" if is_es else "Reload Addon"

	var info_btn = get_node_or_null("%InfoButton") as Button
	if is_instance_valid(info_btn):
		info_btn.text = "Información..." if is_es else "Info..."

	var util_btn = get_node_or_null("%UtilityButton") as Button
	if is_instance_valid(util_btn):
		util_btn.text = "Utilidades..." if is_es else "Utility..."
		util_btn.tooltip_text = "Abrir panel de utilidades" if is_es else "Open utilities panel"

	# 5. Fold button
	var fold_btn = get_node_or_null("%SettingsFoldButton") as Button
	if is_instance_valid(fold_btn):
		fold_btn.tooltip_text = "Alternar lista de configuraciones" if is_es else "Toggle settings list"

	# 6. Info & Utility Panels
	_update_info_panel_language(is_es)
	_update_utility_panel_language(is_es)

	# 7. SettingResource creator panel
	if is_instance_valid(setting_resource_node) and setting_resource_node.has_method("apply_language"):
		setting_resource_node.apply_language(current_language)

	# 8. Array changers
	if is_inside_tree():
		for ac in get_tree().get_nodes_in_group("array_changer"):
			if is_instance_valid(ac) and ac.has_method("apply_language"):
				ac.apply_language(current_language)

		# 9. Social Media
		for sm in get_tree().get_nodes_in_group("social_media"):
			if is_instance_valid(sm) and sm.has_method("apply_language"):
				sm.apply_language(current_language)

		# 10. Delete buttons
		for db in get_tree().get_nodes_in_group("delete_group"):
			if is_instance_valid(db) and db.has_method("apply_language"):
				db.apply_language(current_language)


var utility_panel_node: PanelContainer = null
var is_dragging_utility_panel: bool = false
var drag_utility_panel_offset: Vector2 = Vector2.ZERO


var info_panel_node: PanelContainer = null


func _setup_info_panel() -> void:
	if is_instance_valid(info_panel_node):
		return

	info_panel_node = PanelContainer.new()
	info_panel_node.name = "InfoSummaryPanel"
	info_panel_node.visible = false
	info_panel_node.z_index = 95
	info_panel_node.z_as_relative = false
	info_panel_node.custom_minimum_size = Vector2(360, 320)
	info_panel_node.layout_mode = 0
	info_panel_node.position = Vector2(40, 60)

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
	style.content_margin_left = 14
	style.content_margin_top = 12
	style.content_margin_right = 14
	style.content_margin_bottom = 12
	info_panel_node.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	info_panel_node.add_child(vbox)

	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)

	var title_lbl = Label.new()
	title_lbl.name = "InfoTitleLabel"
	title_lbl.text = "📖 Guía de Game Debugger" if current_language == "ES" else "📖 Game Debugger Guide"
	title_lbl.add_theme_font_size_override("font_size", 15)
	title_lbl.add_theme_color_override("font_color", Color(0.85, 0.75, 1.0, 1.0))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_lbl)

	var close_btn = Button.new()
	close_btn.text = "✖"
	close_btn.flat = true
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	close_btn.pressed.connect(func(): if is_instance_valid(info_panel_node): info_panel_node.hide())
	header_hbox.add_child(close_btn)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var content_lbl = RichTextLabel.new()
	content_lbl.name = "InfoContentLabel"
	content_lbl.bbcode_enabled = true
	content_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(content_lbl)

	add_child(info_panel_node)
	_update_info_panel_language(current_language == "ES")


func _update_info_panel_language(is_es: bool) -> void:
	if not is_instance_valid(info_panel_node):
		return
	var title_lbl = info_panel_node.find_child("InfoTitleLabel", true, false) as Label
	if is_instance_valid(title_lbl):
		title_lbl.text = "📖 Guía de Game Debugger" if is_es else "📖 Game Debugger Guide"

	var content_lbl = info_panel_node.find_child("InfoContentLabel", true, false) as RichTextLabel
	if is_instance_valid(content_lbl):
		if is_es:
			content_lbl.text = """[color=#b895ff][b]1. ➕ Crear Configuraciones Personalizadas[/b][/color]
Haz clic en [color=#85d8ff]"Crear nueva configuración..."[/color] para abrir el creador.
Selecciona un [color=#ffd700]Ajuste[/color] (Bool, Int, Float, String, Enum, Array).
Para [color=#ffd700]Array[/color] o [color=#ffd700]Enum[/color], haz clic en el botón rojo/verde [color=#ff7575]"Crear Elementos..."[/color] para ingresar valores.

[color=#b895ff][b]2. ≡ Arrastrar y Reordenar Configuraciones[/b][/color]
Mantén presionado el [color=#ffd700]Clic Derecho[/color] en cualquier fila o manipulador [color=#85d8ff]≡[/color] para arrastrar y cambiar posiciones en tiempo real. El orden se guarda automáticamente.

[color=#b895ff][b]3. ✏ Ajustar y Eliminar Configuraciones[/b][/color]
Modifica los valores en tiempo real. Los cambios se guardan directamente en [color=#85d8ff]ProjectSettings[/color].
Haz clic en el botón rojo [color=#ff5555]🗑 Eliminar[/color] a la derecha para borrar una configuración permanentemente.

[color=#b895ff][b]4. 🖱 Navegación en el Lienzo[/b][/color]
Mantén presionado el [color=#ffd700]Clic Izquierdo[/color] en un espacio vacío para mover el lienzo. Doble clic izquierdo para reiniciar la vista."""
		else:
			content_lbl.text = """[color=#b895ff][b]1. ➕ Create Custom Settings[/b][/color]
Click [color=#85d8ff]"Create new custom setting..."[/color] to open the setting creator.
Select a [color=#ffd700]Preset[/color] (Bool, Int, Float, String, Enum, Array).
For [color=#ffd700]Array[/color] or [color=#ffd700]Enum[/color], click the red/green [color=#ff7575]"Create Items..."[/color] button to enter values.

[color=#b895ff][b]2. ≡ Drag & Reorder Settings[/b][/color]
Hold [color=#ffd700]Right Click[/color] on any setting row or [color=#85d8ff]≡[/color] handle to drag & swap positions in real time. Order is saved automatically.

[color=#b895ff][b]3. ✏ Adjust & Delete Settings[/b][/color]
Modify values in real time. Changes save directly to [color=#85d8ff]ProjectSettings[/color].
Click the red [color=#ff5555]🗑 Delete Button[/color] on the right to remove a setting permanently.

[color=#b895ff][b]4. 🖱 Canvas Navigation[/b][/color]
Hold [color=#ffd700]Left Click[/color] on empty space to pan the canvas. Double-click left mouse to reset view."""


func _on_info_button_pressed() -> void:
	_setup_info_panel()
	if is_instance_valid(info_panel_node):
		info_panel_node.visible = !info_panel_node.visible
		if info_panel_node.visible:
			var info_btn = get_node_or_null("%InfoButton") as Button
			if is_instance_valid(info_btn):
				var btn_rect = info_btn.get_global_rect()
				info_panel_node.global_position = Vector2(btn_rect.position.x - 180, btn_rect.position.y - 335)
			clamp_control_inside_window(info_panel_node)


func _setup_utility_panel() -> void:
	if is_instance_valid(utility_panel_node):
		return

	utility_panel_node = PanelContainer.new()
	utility_panel_node.name = "UtilitySummaryPanel"
	utility_panel_node.visible = false
	utility_panel_node.z_index = 95
	utility_panel_node.z_as_relative = false
	utility_panel_node.custom_minimum_size = Vector2(300, 200)
	utility_panel_node.layout_mode = 0
	utility_panel_node.position = Vector2(400, 60)

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
	style.content_margin_left = 14
	style.content_margin_top = 12
	style.content_margin_right = 14
	style.content_margin_bottom = 12
	utility_panel_node.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	utility_panel_node.add_child(vbox)

	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)

	var title_lbl = Label.new()
	title_lbl.name = "UtilityTitleLabel"
	title_lbl.text = "🛠 Utilidades de Debug" if current_language == "ES" else "🛠 Debug Utilities"
	title_lbl.add_theme_font_size_override("font_size", 15)
	title_lbl.add_theme_color_override("font_color", Color(0.85, 0.75, 1.0, 1.0))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_lbl)

	var close_btn = Button.new()
	close_btn.text = "✖"
	close_btn.flat = true
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	close_btn.pressed.connect(func(): if is_instance_valid(utility_panel_node): utility_panel_node.hide())
	header_hbox.add_child(close_btn)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(content_vbox)

	var desc_lbl = Label.new()
	desc_lbl.name = "UtilityDescLabel"
	desc_lbl.text = "Herramientas de diagnóstico y rendimiento:" if current_language == "ES" else "Diagnostic and performance tools:"
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.7, 0.85, 1.0))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_vbox.add_child(desc_lbl)

	# Benchmark Button (no icon, pure text)
	var bench_btn = Button.new()
	bench_btn.name = "UtilityBenchmarkButton"
	bench_btn.text = "Benchmark Plugin"
	bench_btn.custom_minimum_size = Vector2(0, 32)
	bench_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bench_btn.focus_mode = Control.FOCUS_NONE
	bench_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.24, 0.18, 0.45, 1.0)
	btn_normal.border_width_left = 1
	btn_normal.border_width_top = 1
	btn_normal.border_width_right = 1
	btn_normal.border_width_bottom = 1
	btn_normal.border_color = Color(0.65, 0.45, 0.95, 0.8)
	btn_normal.corner_radius_top_left = 5
	btn_normal.corner_radius_top_right = 5
	btn_normal.corner_radius_bottom_right = 5
	btn_normal.corner_radius_bottom_left = 5
	btn_normal.content_margin_left = 10
	btn_normal.content_margin_right = 10
	btn_normal.content_margin_top = 6
	btn_normal.content_margin_bottom = 6

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.32, 0.25, 0.58, 1.0)
	btn_hover.border_color = Color(0.85, 0.65, 1.0, 1.0)

	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.18, 0.12, 0.35, 1.0)

	bench_btn.add_theme_stylebox_override("normal", btn_normal)
	bench_btn.add_theme_stylebox_override("hover", btn_hover)
	bench_btn.add_theme_stylebox_override("pressed", btn_pressed)
	bench_btn.pressed.connect(func(): run_plugin_benchmark())
	content_vbox.add_child(bench_btn)

	add_child(utility_panel_node)
	_update_utility_panel_language(current_language == "ES")


func _update_utility_panel_language(is_es: bool) -> void:
	if not is_instance_valid(utility_panel_node):
		return
	var title_lbl = utility_panel_node.find_child("UtilityTitleLabel", true, false) as Label
	if is_instance_valid(title_lbl):
		title_lbl.text = "🛠 Utilidades de Debug" if is_es else "🛠 Debug Utilities"

	var desc_lbl = utility_panel_node.find_child("UtilityDescLabel", true, false) as Label
	if is_instance_valid(desc_lbl):
		desc_lbl.text = "Herramientas de diagnóstico y rendimiento:" if is_es else "Diagnostic and performance tools:"

	var bench_btn = utility_panel_node.find_child("UtilityBenchmarkButton", true, false) as Button
	if is_instance_valid(bench_btn):
		bench_btn.text = "Benchmark Plugin"


func _on_utility_button_pressed() -> void:
	_setup_utility_panel()
	if is_instance_valid(utility_panel_node):
		utility_panel_node.visible = !utility_panel_node.visible
		if utility_panel_node.visible:
			var sm: Control = null
			if has_node("%SocialIconsContainer"):
				sm = get_node("%SocialIconsContainer").find_child("SocialMedia", true, false) as Control
			if sm == null and is_inside_tree():
				var sm_list = get_tree().get_nodes_in_group("social_media")
				if sm_list.size() > 0:
					sm = sm_list[0] as Control

			if is_instance_valid(sm):
				var sm_rect = sm.get_global_rect()
				utility_panel_node.global_position = Vector2(sm_rect.position.x + sm_rect.size.x + 15, sm_rect.position.y)
			else:
				var util_btn = get_node_or_null("%UtilityButton") as Button
				if is_instance_valid(util_btn):
					var btn_rect = util_btn.get_global_rect()
					utility_panel_node.global_position = Vector2(btn_rect.position.x - 100, btn_rect.position.y - 250)
				else:
					utility_panel_node.global_position = Vector2(size.x - 340, 80)
			clamp_control_inside_window(utility_panel_node)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		call_deferred("_apply_panning_and_clamping")
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_WM_MOUSE_EXIT:
		is_panning = false
		is_dragging_setting_resource = false
		is_dragging_info_panel = false
		is_dragging_utility_panel = false


func _on_main_view_resized() -> void:
	_apply_panning_and_clamping()


func _input(event: InputEvent) -> void:
	if not visible or not is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var click_pos = event.global_position
			var view_rect = get_global_rect()

			if event.pressed:
				# 0. Drag UtilitySummaryPanel window independently
				if is_instance_valid(utility_panel_node) and utility_panel_node.visible:
					var util_rect = utility_panel_node.get_global_rect()
					if util_rect.has_point(click_pos):
						var hover = get_viewport().gui_get_hovered_control()
						if is_instance_valid(hover) and hover is BaseButton and (hover.text == "✖" or hover.name == "UtilityBenchmarkButton"):
							is_panning = false
							is_dragging_utility_panel = false
							return

						is_dragging_utility_panel = true
						drag_utility_panel_offset = click_pos - utility_panel_node.global_position
						is_panning = false
						get_viewport().set_input_as_handled()
						return

				# 1. Drag InfoSummaryPanel window independently
				if is_instance_valid(info_panel_node) and info_panel_node.visible:
					var info_rect = info_panel_node.get_global_rect()
					if info_rect.has_point(click_pos):
						var hover = get_viewport().gui_get_hovered_control()
						if is_instance_valid(hover) and hover is BaseButton and hover.text == "✖":
							is_panning = false
							is_dragging_info_panel = false
							return

						is_dragging_info_panel = true
						drag_info_panel_offset = click_pos - info_panel_node.global_position
						is_panning = false
						get_viewport().set_input_as_handled()
						return

				# 2. Drag SettingResource window independently
				if is_instance_valid(setting_resource_node) and setting_resource_node.visible:
					var sr_rect = setting_resource_node.get_global_rect()
					if sr_rect.has_point(click_pos):
						var hover = get_viewport().gui_get_hovered_control()
						if is_instance_valid(hover) and (hover is OptionButton or hover is LineEdit or hover is BaseButton):
							is_panning = false
							is_dragging_setting_resource = false
							return

						is_dragging_setting_resource = true
						if "has_user_dragged" in setting_resource_node:
							setting_resource_node.set("has_user_dragged", true)
						drag_setting_resource_offset = click_pos - setting_resource_node.global_position
						is_panning = false
						get_viewport().set_input_as_handled()
						return

				# 3. Canvas panning on background
				if view_rect.has_point(click_pos):
					if _is_clicking_interactive_control():
						is_panning = false
						return

					if event.double_click:
						pan_offset = Vector2.ZERO
						is_panning = false
						_apply_panning_and_clamping()
					else:
						is_panning = true
						drag_start_mouse = click_pos
						drag_start_offset = pan_offset
			else:
				is_dragging_setting_resource = false
				is_dragging_info_panel = false
				is_dragging_utility_panel = false
				is_panning = false

	elif event is InputEventMouseMotion:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			is_panning = false
			is_dragging_setting_resource = false
			is_dragging_info_panel = false
			is_dragging_utility_panel = false
			return

		if is_dragging_utility_panel and is_instance_valid(utility_panel_node):
			utility_panel_node.global_position = event.global_position - drag_utility_panel_offset
			clamp_control_inside_window(utility_panel_node)
			get_viewport().set_input_as_handled()

		elif is_dragging_info_panel and is_instance_valid(info_panel_node):
			info_panel_node.global_position = event.global_position - drag_info_panel_offset
			clamp_control_inside_window(info_panel_node)
			get_viewport().set_input_as_handled()

		elif is_dragging_setting_resource and is_instance_valid(setting_resource_node):


			setting_resource_node.global_position = event.global_position - drag_setting_resource_offset
			clamp_control_inside_window(setting_resource_node)
			if is_instance_valid(text_edit_main) and text_edit_main.visible:
				var sr_rect = setting_resource_node.get_global_rect()
				text_edit_main.global_position = Vector2(sr_rect.position.x + sr_rect.size.x + 10.0, sr_rect.position.y)
				clamp_control_inside_window(text_edit_main)
			get_viewport().set_input_as_handled()

		elif is_panning:
			var delta = event.global_position - drag_start_mouse
			pan_offset = drag_start_offset + delta
			_apply_panning_and_clamping()



func _is_clicking_interactive_control() -> bool:
	if not is_inside_tree() or get_viewport() == null:
		return false
	var hover = get_viewport().gui_get_hovered_control()
	if is_instance_valid(hover):
		# If clicking inside SettingResource, TextEditOption, MainViewManager, InfoPanel, or UtilityPanel: DO NOT pan canvas!
		if _is_node_or_ancestor_equal(hover, setting_resource_node) or _is_node_or_ancestor_equal(hover, text_edit_main) or _is_node_or_ancestor_equal(hover, main_view_manager) or _is_node_or_ancestor_equal(hover, info_panel_node) or _is_node_or_ancestor_equal(hover, utility_panel_node):
			return true

		if hover is BaseButton or hover is Button or hover is LineEdit or hover is SpinBox or hover is OptionButton or hover is TextEdit or hover is CheckButton:
			return true
		var p = hover.get_parent()
		if is_instance_valid(p) and (p is SpinBox or p is OptionButton or p is LineEdit or p is BaseButton or p is Button or p is TextEdit):
			return true
	return false



func _is_node_or_ancestor_equal(node: Node, target: Node) -> bool:
	if not is_instance_valid(node) or not is_instance_valid(target):
		return false
	var current: Node = node
	while is_instance_valid(current):
		if current == target:
			return true
		current = current.get_parent()
	return false



func _apply_panning_and_clamping() -> void:
	var view_size = size
	if view_size.x <= 0 or view_size.y <= 0:
		return

	var max_pan_x = max(200.0, view_size.x * 0.45)
	var max_pan_y = max(200.0, view_size.y * 0.45)

	pan_offset.x = clamp(pan_offset.x, -max_pan_x, max_pan_x)
	pan_offset.y = clamp(pan_offset.y, -max_pan_y, max_pan_y)

	if is_instance_valid(main_center_container):
		main_center_container.position = pan_offset

	if is_instance_valid(bg_center_container):
		bg_center_container.position = pan_offset

	if is_instance_valid(margin_container):
		margin_container.position = pan_offset

	clamp_all_popups()




func clamp_all_popups() -> void:
	clamp_control_inside_window(setting_resource_node)
	clamp_control_inside_window(text_edit_main)
	clamp_control_inside_window(info_panel_node)
	clamp_control_inside_window(utility_panel_node)


func clamp_control_inside_window(node: Control) -> void:
	if not is_instance_valid(node) or not node.visible:
		return

	var view_rect = get_global_rect()
	if view_rect.size.x <= 0 or view_rect.size.y <= 0:
		return

	var node_rect = node.get_global_rect()
	var margin = 6.0

	var min_x = view_rect.position.x + margin
	var max_x = view_rect.position.x + max(0.0, view_rect.size.x - node_rect.size.x - margin)
	var min_y = view_rect.position.y + margin
	var max_y = view_rect.position.y + max(0.0, view_rect.size.y - node_rect.size.y - margin)

	if max_x < min_x:
		max_x = min_x
	if max_y < min_y:
		max_y = min_y

	var target_x = clamp(node_rect.position.x, min_x, max_x)
	var target_y = clamp(node_rect.position.y, min_y, max_y)

	node.global_position = Vector2(target_x, target_y)


func update_plugin()->void:
	setting_resource_node = $SettingCreatorContainer/SettingResourceManager/SettingResource
	project_settings_debug = $ProjectSettingsDebug
	main_view_manager = $MainCenterContainer/MainViewManager
	main_center_container = %MainCenterContainer
	text_edit_main = $SettingCreatorContainer/SettingResourceManager/TextEditOption
	if is_instance_valid(setting_resource) and "main_view" in setting_resource:
		setting_resource.set("main_view", self)

	res_prop = ResProperty.new()
#	var loaded_res = load_resources_from_user()
#	setting_resource.load_res(loaded_res)
	project_settings_debug._set_up_settings()
	if is_instance_valid(main_view_manager):
		main_view_manager.main_view = self
		main_view_manager.update_settings()
	apply_language(current_language)



func remove_overwrite_setting(setting_name: String) -> void:
	if current_settings.is_empty():
		load_resources_from_user()  # Make sure we have the latest in-memory

	var found := false
	for i in range(current_settings.size()):
		var resource = current_settings[i]
		if resource and resource is CustomSetting and resource.name == setting_name:
			current_settings.remove_at(i)
			found = true
			break

	if not found:
		push_warning("⚠ Resource with name '%s' not found!" % setting_name)
		return

	# Save updated settings
	var container = ContainerCustomSetting.new()
	container.settings = current_settings.duplicate(true)
	var err = ResourceSaver.save(container, save_resource_file)
	if err != OK:
		push_warning("⚠ Failed to save container after removing '%s'!" % setting_name)
		return

	pass # print(current_settings, "✅ Removed setting '%s' successfully" % setting_name)


func reorder_settings(from_index: int, to_index: int) -> void:
	if current_settings.is_empty():
		load_resources_from_user()

	if from_index < 0 or from_index >= current_settings.size():
		return
	if to_index < 0 or to_index >= current_settings.size():
		return
	if from_index == to_index:
		return

	var moved_resource = current_settings[from_index]
	current_settings.remove_at(from_index)
	current_settings.insert(to_index, moved_resource)

	save_resources_to_user(current_settings)
	update_plugin()






func save_overwrite_setting(setting_name: String, new_value) -> void:
	# Load a writable copy of the container
	var container: ContainerCustomSetting = ResourceLoader.load(save_resource_file, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not container:
		push_warning("⚠ Failed to load container resource!")
		return

	# Find the resource by name
	for resource in container.settings:
		if resource and resource is CustomSetting and resource.name == setting_name:
			# --- Case 1: PackedStringArray with hint = TYPE_STRING ---
			if resource.type == TYPE_PACKED_STRING_ARRAY and resource.hint == PROPERTY_HINT_TYPE_STRING:
				resource.array_value = PackedStringArray(new_value)

			# --- Case 2: Boolean ---
			elif resource.type == TYPE_BOOL:
				resource.bool_value = bool(new_value)

			# --- Case 3: String with enum hint ---
			elif resource.type == TYPE_STRING and resource.hint == PROPERTY_HINT_ENUM:
				resource.default_value = str(new_value)

			# --- Case 4: Integer ---
			elif resource.type == TYPE_INT:
				resource.int_value = int(new_value)

			# --- Case 5: Float ---
			elif resource.type == TYPE_FLOAT:
				resource.float_value = float(new_value)

			else:
				push_warning("⚠ Unsupported type/hint for resource: %s" % resource.name, "res type:", resource.type)
				return

			# Save container back to disk
			var err = ResourceSaver.save(container, save_resource_file)
			if err != OK:
				push_warning("⚠ Failed to save container resource: " + str(save_resource_file))
				return

			# 🔑 Sync current_settings to match saved container
			current_settings = container.settings.duplicate(true) # deep copy so it’s writable
			return

	push_warning("⚠ Resource with name '%s' not found in container!" % setting_name)





var current_settings:Array[CustomSetting]



func save_resources_to_user(resources_settings: Array[CustomSetting]) -> void:
	# Always create a fresh container
	var container := ContainerCustomSetting.new()
	
	# Store only the live references
	container.settings = []
	for s in resources_settings:
		if s != null and s is CustomSetting:
			container.settings.append(s)
	# Update in-memory reference
	current_settings = container.settings

	# Save
	var err := ResourceSaver.save(container, save_resource_file)
	if err != OK:
		push_warning("⚠ Failed to save resources! Error code: %s" % err)
	else:
		var names := []
		for s in current_settings:
			names.append(s.name)



func load_resources_from_user() -> Array[CustomSetting]:
	var out: Array[CustomSetting] = []

	# If no file, keep memory clean
	if not FileAccess.file_exists(save_resource_file):
		current_settings = out
		return current_settings

	# Load FRESH from disk (ignore cache to avoid stale/zombie data)
	var container := ResourceLoader.load(save_resource_file, "", ResourceLoader.CACHE_MODE_IGNORE) as ContainerCustomSetting
	if container == null:
		current_settings = out
		return current_settings

	# Build a brand-new WRITABLE array (do NOT keep the resource's internal array reference)
	for r in container.settings:
		if r != null and r is CustomSetting:
			out.append(r)  # same instances, but the array itself is writable

	# Replace in-memory source of truth
	current_settings = out
	notify_property_list_changed()

	# Debug
	var names := PackedStringArray()
	for s in current_settings:
		names.append(s.name)
	#print("📂 Loaded settings:", names)

	return current_settings





func position_setting_resource_default(force_reset: bool = false) -> void:
	if not is_instance_valid(setting_resource_node):
		return

	var has_dragged: bool = bool(setting_resource_node.get("has_user_dragged")) if "has_user_dragged" in setting_resource_node else false
	if not has_dragged or force_reset:
		var banner = main_center_container.get_node_or_null("PanelContainer/MainImage") if is_instance_valid(main_center_container) else null
		var view_rect = get_global_rect()
		if is_instance_valid(banner):
			var banner_rect = banner.get_global_rect()
			var default_x = banner_rect.position.x - 310.0
			if default_x < view_rect.position.x + 15.0:
				default_x = view_rect.position.x + 15.0

			var default_y = max(40.0, banner_rect.position.y - 10.0)
			setting_resource_node.global_position = Vector2(default_x, default_y)
		else:
			setting_resource_node.global_position = Vector2(view_rect.position.x + 15.0, view_rect.position.y + 60.0)

	clamp_all_popups()




func _on_new_setting_button_pressed() -> void:
	setting_resource_node.visible = !setting_resource_node.visible
	if is_instance_valid(get_tree()):
		var _array_changers: Array = get_tree().get_nodes_in_group("array_changer")
		if _array_changers.size() > 1:
			for i in _array_changers:
				i.hide()

	if text_edit_main.visible:
		text_edit_main.visible = false

	if setting_resource_node.visible:
		call_deferred("position_setting_resource_default")


func _on_reload_button_pressed() -> void:
	if Engine.is_editor_hint():
		if EditorInterface.has_method("set_plugin_enabled"):
			EditorInterface.set_plugin_enabled("game_debugger", false)
			EditorInterface.set_plugin_enabled("game_debugger", true)
			if EditorInterface.has_method("set_main_screen_editor"):
				EditorInterface.call_deferred("set_main_screen_editor", "GameDebugger")
			return
	update_plugin()


func _on_benchmark_button_pressed() -> void:
	run_plugin_benchmark()


func run_plugin_benchmark() -> void:
	var t_start = Time.get_ticks_usec()
	
	# 1. Measure node references & state setup
	var t_nodes_0 = Time.get_ticks_usec()
	setting_resource_node = $SettingCreatorContainer/SettingResourceManager/SettingResource
	project_settings_debug = $ProjectSettingsDebug
	main_view_manager = $MainCenterContainer/MainViewManager
	main_center_container = %MainCenterContainer
	text_edit_main = $SettingCreatorContainer/SettingResourceManager/TextEditOption
	if is_instance_valid(setting_resource) and "main_view" in setting_resource:
		setting_resource.set("main_view", self)
	res_prop = ResProperty.new()
	var t_nodes_ms = (Time.get_ticks_usec() - t_nodes_0) / 1000.0
	
	# 2. Measure ProjectSettings setup & parsing
	var t_proj_0 = Time.get_ticks_usec()
	if is_instance_valid(project_settings_debug):
		project_settings_debug._set_up_settings()
	var t_proj_ms = (Time.get_ticks_usec() - t_proj_0) / 1000.0
	
	# 3. Measure UI Options dynamic creation & update
	var t_mvm_0 = Time.get_ticks_usec()
	if is_instance_valid(main_view_manager):
		main_view_manager.main_view = self
		main_view_manager.update_settings()
	var t_mvm_ms = (Time.get_ticks_usec() - t_mvm_0) / 1000.0
	
	# 4. Measure Language & Localization pass
	var t_lang_0 = Time.get_ticks_usec()
	apply_language(current_language)
	var t_lang_ms = (Time.get_ticks_usec() - t_lang_0) / 1000.0
	
	var total_bench_ms = (Time.get_ticks_usec() - t_start) / 1000.0
	
	print_rich("\n[color=orange]==================================================[/color]")
	print_rich("[color=orange]   GAMEDEBUGGER PLUGIN BENCHMARK (EDITOR REBUILD) [/color]")
	print_rich("[color=orange]   [Notice: Measuring Editor UI / NOT Gameplay]   [/color]")
	print_rich("[color=orange]   [Note: This plugin only runs at the editor level] (0.000 ms gameplay impact)[/color]")
	print_rich("[color=orange]==================================================[/color]")
	print_rich("[color=orange][BENCHMARK] [GameDebugger] Node References & State:     %.3f ms[/color] [color=light_blue](%.6f s)[/color]" % [t_nodes_ms, t_nodes_ms / 1000.0])
	print_rich("[color=orange][BENCHMARK] [GameDebugger] ProjectSettings Parsing:     %.3f ms[/color] [color=light_blue](%.6f s)[/color]" % [t_proj_ms, t_proj_ms / 1000.0])
	print_rich("[color=orange][BENCHMARK] [GameDebugger] UI Options Generation:       %.3f ms[/color] [color=light_blue](%.6f s)[/color]" % [t_mvm_ms, t_mvm_ms / 1000.0])
	print_rich("[color=orange][BENCHMARK] [GameDebugger] Localization Pass:            %.3f ms[/color] [color=light_blue](%.6f s)[/color]" % [t_lang_ms, t_lang_ms / 1000.0])
	print_rich("[color=orange]--------------------------------------------------[/color]")
	print_rich("[color=orange][BENCHMARK] >> TOTAL EDITOR PLUGIN REBUILD: %.3f ms[/color] [color=light_blue](%.6f s)[/color] [color=orange]<<[/color]" % [total_bench_ms, total_bench_ms / 1000.0])
	print_rich("[color=orange]==================================================[/color]\n")
