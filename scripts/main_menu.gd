extends Control

const MIN_VOLUME_DB := -80.0

@onready var start_button := $MarginContainer/Content/StartButton as Button
@onready var settings_button := $MarginContainer/Content/SettingsButton as Button
@onready var help_button := $MarginContainer/Content/HelpButton as Button
@onready var credits_button := $MarginContainer/Content/CreditsButton as Button
@onready var settings_layer := $SettingsLayer as ColorRect
@onready var volume_slider := $SettingsLayer/SettingsPanel/MarginContainer/Content/VolumeSlider as HSlider
@onready var volume_value_label := $SettingsLayer/SettingsPanel/MarginContainer/Content/VolumeValue as Label
@onready var settings_back_button := $SettingsLayer/SettingsPanel/MarginContainer/Content/BackButton as Button
@onready var help_layer := $HelpLayer as ColorRect
@onready var help_back_button := $HelpLayer/HelpPanel/MarginContainer/Content/BackButton as Button
@onready var credits_layer := $CreditsLayer as ColorRect
@onready var credits_back_button := $CreditsLayer/CreditsPanel/MarginContainer/Content/BackButton as Button


func _ready() -> void:
	start_button.grab_focus()
	start_button.pressed.connect(_on_start_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	help_button.pressed.connect(_on_help_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	settings_back_button.pressed.connect(_on_settings_back_button_pressed)
	help_back_button.pressed.connect(_on_help_back_button_pressed)
	credits_back_button.pressed.connect(_on_credits_back_button_pressed)
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	_sync_volume_slider()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_settings_button_pressed() -> void:
	settings_layer.visible = true
	volume_slider.grab_focus()


func _on_help_button_pressed() -> void:
	help_layer.visible = true
	help_back_button.grab_focus()


func _on_credits_button_pressed() -> void:
	credits_layer.visible = true
	credits_back_button.grab_focus()


func _on_settings_back_button_pressed() -> void:
	settings_layer.visible = false
	settings_button.grab_focus()


func _on_help_back_button_pressed() -> void:
	help_layer.visible = false
	help_button.grab_focus()


func _on_credits_back_button_pressed() -> void:
	credits_layer.visible = false
	credits_button.grab_focus()


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
	volume_value_label.text = "Volume: %d%%" % int(round(value * 100.0))
