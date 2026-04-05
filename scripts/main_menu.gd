extends Control


func _ready() -> void:
	var start_button := $MarginContainer/Content/StartButton as Button
	start_button.grab_focus()
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
