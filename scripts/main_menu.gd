extends Control

const MIN_VOLUME_DB := -80.0

@onready var start_button := $MarginContainer/Content/StartButton as Button
@onready var settings_button := $MarginContainer/Content/SettingsButton as Button
@onready var help_button := $MarginContainer/Content/HelpButton as Button
@onready var settings_layer := $SettingsLayer as ColorRect
@onready var volume_slider := $SettingsLayer/SettingsPanel/MarginContainer/Content/VolumeSlider as HSlider
@onready var volume_value_label := $SettingsLayer/SettingsPanel/MarginContainer/Content/VolumeValue as Label
@onready var settings_back_button := $SettingsLayer/SettingsPanel/MarginContainer/Content/BackButton as Button
@onready var help_layer := $HelpLayer as ColorRect
@onready var help_back_button := $HelpLayer/HelpPanel/MarginContainer/Content/BackButton as Button


func _ready() -> void:
	_apply_chinese_labels()
	_apply_showcase_skin()
	start_button.grab_focus()
	start_button.pressed.connect(_on_start_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	help_button.pressed.connect(_on_help_button_pressed)
	settings_back_button.pressed.connect(_on_settings_back_button_pressed)
	help_back_button.pressed.connect(_on_help_back_button_pressed)
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	_sync_volume_slider()
	if _is_autoplay_enabled():
		call_deferred("_on_start_button_pressed")


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_settings_button_pressed() -> void:
	settings_layer.visible = true
	volume_slider.grab_focus()


func _on_help_button_pressed() -> void:
	help_layer.visible = true
	help_back_button.grab_focus()


func _on_settings_back_button_pressed() -> void:
	settings_layer.visible = false
	settings_button.grab_focus()


func _on_help_back_button_pressed() -> void:
	help_layer.visible = false
	help_button.grab_focus()


func _on_volume_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	var volume_db := MIN_VOLUME_DB if value <= 0.0 else linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	_update_volume_label(value)


func _sync_volume_slider() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	var volume_db := AudioServer.get_bus_volume_db(bus_index)
	var linear_volume := 0.0 if volume_db <= MIN_VOLUME_DB else db_to_linear(volume_db)
	volume_slider.set_value_no_signal(clamp(linear_volume, 0.0, 1.0))
	_update_volume_label(volume_slider.value)


func _update_volume_label(value: float) -> void:
	volume_value_label.text = "音量：%d%%" % int(round(value * 100.0))


func _is_autoplay_enabled() -> bool:
	return OS.get_cmdline_user_args().has("--autoplay")


func _apply_chinese_labels() -> void:
	$VersionBadge.text = "展示版本 0.17"
	$MarginContainer/Content/Title.text = "星际战斗展示"
	$MarginContainer/Content/Subtitle.text = "横版太空射击 · 单局试玩流程"
	$MarginContainer/Content/Description.text = "穿过航线、击毁目标、保留结算结果。手机竖屏访问时建议旋转到横屏。"
	start_button.text = "开始展示试玩"
	settings_button.text = "设置"
	help_button.text = "说明"
	$MarginContainer/Content/Hint.text = "Enter / 点击按钮开始。移动、射击、结算都在一局内完成。"
	$SettingsLayer/SettingsPanel/MarginContainer/Content/Title.text = "试玩设置"
	$SettingsLayer/SettingsPanel/MarginContainer/Content/Description.text = "开始前可调整整体音量。\n版本：展示版本 0.17"
	$SettingsLayer/SettingsPanel/MarginContainer/Content/VolumeLabel.text = "主音量"
	$SettingsLayer/SettingsPanel/MarginContainer/Content/Note.text = "当前版本的音频内容较轻量，此滑块用于设置展示音量。"
	settings_back_button.text = "返回菜单"
	$HelpLayer/HelpPanel/MarginContainer/Content/Title.text = "试玩说明"
	$HelpLayer/HelpPanel/MarginContainer/Content/Description.text = "这是一个使用 Godot 制作的轻量级单局太空射击展示。\n版本：展示版本 0.17"
	$HelpLayer/HelpPanel/MarginContainer/Content/Controls.text = "操作：\n- 移动：WASD 或方向键\n- 射击：Space 或 Enter\n- 暂停：Esc\n- 结束后：R 重新开始，M 或 Esc 返回菜单"
	$HelpLayer/HelpPanel/MarginContainer/Content/Note.text = "开始前可以在这里快速查看当前试玩路线的操作。"
	help_back_button.text = "返回菜单"


func _apply_showcase_skin() -> void:
	$Background.color = Color(0.018, 0.025, 0.052, 1.0)
	$VersionBadge.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48))

	var menu_frame := $MarginContainer as MarginContainer
	var target_index := menu_frame.get_index()

	var signal_band := ColorRect.new()
	signal_band.name = "ShowcaseSignalBand"
	signal_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	signal_band.color = Color(0.11, 0.17, 0.36, 0.42)
	signal_band.set_anchors_preset(Control.PRESET_CENTER)
	signal_band.offset_left = -360.0
	signal_band.offset_top = -120.0
	signal_band.offset_right = 360.0
	signal_band.offset_bottom = 120.0
	add_child(signal_band)
	move_child(signal_band, target_index)

	var card := PanelContainer.new()
	card.name = "ShowcaseCard"
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = menu_frame.offset_left - 24.0
	card.offset_top = menu_frame.offset_top - 46.0
	card.offset_right = menu_frame.offset_right + 24.0
	card.offset_bottom = menu_frame.offset_bottom + 24.0
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.065, 0.12, 0.94), Color(0.44, 0.72, 1.0, 0.72), 2))
	add_child(card)
	move_child(card, target_index + 1)

	$MarginContainer/Content/Title.add_theme_font_size_override("font_size", 38)
	$MarginContainer/Content/Subtitle.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48))
	$MarginContainer/Content/Description.add_theme_font_size_override("font_size", 18)
	$MarginContainer/Content/Hint.add_theme_font_size_override("font_size", 15)

	_apply_button_style(start_button, Color(0.42, 0.68, 1.0), true)
	_apply_button_style(settings_button, Color(0.58, 0.78, 0.96), false)
	_apply_button_style(help_button, Color(0.58, 0.78, 0.96), false)
	_apply_button_style(settings_back_button, Color(0.58, 0.78, 0.96), false)
	_apply_button_style(help_back_button, Color(0.58, 0.78, 0.96), false)

	$SettingsLayer/SettingsPanel.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.075, 0.13, 0.98), Color(0.58, 0.78, 0.96, 0.78), 2))
	$HelpLayer/HelpPanel.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.075, 0.13, 0.98), Color(0.58, 0.78, 0.96, 0.78), 2))


func _apply_button_style(button: Button, accent: Color, primary: bool) -> void:
	var fill := Color(0.08, 0.10, 0.16, 1.0).lerp(accent, 0.24 if primary else 0.10)
	button.add_theme_stylebox_override("normal", _panel_style(fill, accent, 1))
	button.add_theme_stylebox_override("hover", _panel_style(fill.lerp(accent, 0.18), accent, 1))
	button.add_theme_stylebox_override("pressed", _panel_style(Color(0.04, 0.05, 0.08, 1.0).lerp(accent, 0.20), accent, 1))
	button.add_theme_stylebox_override("focus", _panel_style(fill.lerp(accent, 0.28), accent, 2))
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.04, 0.05, 0.08))


func _panel_style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 14.0
	style.content_margin_top = 10.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 10.0
	return style
