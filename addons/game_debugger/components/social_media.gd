@tool
extends Control

const YOUTUBE_URL = "https://youtube.com/@samuraikina5908?si=XgnADjqgPl9r4gkE"
const X_URL = "https://x.com/CiisoB"
const TIKTOK_URL = "https://www.tiktok.com/@samuraikina_anticodec?_r=1&_t=ZS-99Kq2eaTilh"
const INSTAGRAM_URL = "https://www.instagram.com/anticodec507?igsi=MWExbjk3cWI1aHp1MQ=="
const REDDIT_URL = "https://www.reddit.com/u/Ciso507/s/4LknXFIVvX"

@onready var youtube_icon: TextureRect = $VBoxContainer/TextureRect
@onready var x_icon: TextureRect = $VBoxContainer/TextureRect2
@onready var tiktok_icon: TextureRect = $VBoxContainer/TextureRect3
@onready var instagram_icon: TextureRect = $VBoxContainer/TextureRect5
@onready var reddit_icon: TextureRect = $VBoxContainer/TextureRect4


var current_language: String = "EN"


func _ready() -> void:
	if is_inside_tree():
		var mvs = get_tree().get_nodes_in_group("main_view")
		if mvs.size() > 0 and "current_language" in mvs[0]:
			current_language = mvs[0].get("current_language")
	_setup_icon(youtube_icon, YOUTUBE_URL, "YouTube")
	_setup_icon(x_icon, X_URL, "X (Twitter)")
	_setup_icon(tiktok_icon, TIKTOK_URL, "TikTok")
	_setup_icon(instagram_icon, INSTAGRAM_URL, "Instagram")
	_setup_icon(reddit_icon, REDDIT_URL, "Reddit")
	apply_language(current_language)


func apply_language(lang_code: String) -> void:
	current_language = lang_code
	var prefix = "Sígueme en: " if current_language == "ES" else "Follow me on: "
	if is_instance_valid(youtube_icon): youtube_icon.tooltip_text = prefix + "YouTube"
	if is_instance_valid(x_icon): x_icon.tooltip_text = prefix + "X (Twitter)"
	if is_instance_valid(tiktok_icon): tiktok_icon.tooltip_text = prefix + "TikTok"
	if is_instance_valid(instagram_icon): instagram_icon.tooltip_text = prefix + "Instagram"
	if is_instance_valid(reddit_icon): reddit_icon.tooltip_text = prefix + "Reddit"


func _setup_icon(icon: TextureRect, url: String, platform_name: String) -> void:
	if not is_instance_valid(icon):
		return

	icon.mouse_filter = Control.MOUSE_FILTER_STOP
	icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var prefix = "Sígueme en: " if current_language == "ES" else "Follow me on: "
	icon.tooltip_text = prefix + platform_name


	if not icon.gui_input.is_connected(_on_icon_gui_input.bind(url)):
		icon.gui_input.connect(_on_icon_gui_input.bind(url))
	if not icon.mouse_entered.is_connected(_on_icon_mouse_entered.bind(icon)):
		icon.mouse_entered.connect(_on_icon_mouse_entered.bind(icon))
	if not icon.mouse_exited.is_connected(_on_icon_mouse_exited.bind(icon)):
		icon.mouse_exited.connect(_on_icon_mouse_exited.bind(icon))


func _on_icon_gui_input(event: InputEvent, url: String) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			OS.shell_open(url)


func _on_icon_mouse_entered(icon: TextureRect) -> void:
	if is_instance_valid(icon):
		icon.modulate = Color(1.25, 1.25, 1.25, 1.0)


func _on_icon_mouse_exited(icon: TextureRect) -> void:
	if is_instance_valid(icon):
		icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
