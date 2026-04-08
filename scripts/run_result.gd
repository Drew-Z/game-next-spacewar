extends Control

@onready var result_title_label := $MarginContainer/PanelContainer/MarginContainer/Content/ResultTitle as Label
@onready var result_body_label := $MarginContainer/PanelContainer/MarginContainer/Content/ResultBody as Label
@onready var replay_button := $MarginContainer/PanelContainer/MarginContainer/Content/ReplayButton as Button
@onready var menu_button := $MarginContainer/PanelContainer/MarginContainer/Content/MenuButton as Button


func _ready() -> void:
	replay_button.pressed.connect(_on_replay_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	replay_button.grab_focus()
	result_title_label.text = RunResultState.outcome_title
	result_body_label.text = "\n".join([
		RunResultState.outcome_text,
		"Destroyed: %d/%d" % [RunResultState.destroyed_count, RunResultState.total_targets],
		RunResultState.summary_text,
		"Replay: Press R or select Play Again",
		"Menu: Press M or select Return to Main Menu",
		RunResultState.build_text,
	])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			_on_replay_button_pressed()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_M or event.physical_keycode == KEY_ESCAPE:
			_on_menu_button_pressed()
			get_viewport().set_input_as_handled()


func _on_replay_button_pressed() -> void:
	RunResultState.reset()
	get_tree().change_scene_to_file(RunResultState.GAME_SCENE_PATH)


func _on_menu_button_pressed() -> void:
	RunResultState.reset()
	get_tree().change_scene_to_file(RunResultState.MENU_SCENE_PATH)
