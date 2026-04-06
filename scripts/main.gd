extends Node2D

@onready var player := $Player
@onready var health_label := $HUD/HealthLabel as Label
@onready var pause_hint_label := $HUD/PauseHintLabel as Label
@onready var result_panel := $HUD/ResultPanel as PanelContainer
@onready var result_title_label := $HUD/ResultPanel/MarginContainer/Content/ResultTitle as Label
@onready var result_body_label := $HUD/ResultPanel/MarginContainer/Content/ResultBody as Label
@onready var pause_panel := $HUD/PausePanel as PanelContainer
@onready var continue_button := $HUD/PausePanel/MarginContainer/Content/ContinueButton as Button
@onready var back_to_menu_button := $HUD/PausePanel/MarginContainer/Content/BackToMenuButton as Button

var cleared_enemy_targets := 0
var resolved_enemy_targets := 0
var total_enemy_targets := 0
var is_cleared := false
var is_failed := false
var is_paused := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)
	continue_button.pressed.connect(_on_continue_button_pressed)
	back_to_menu_button.pressed.connect(_on_back_to_menu_button_pressed)

	cleared_enemy_targets = 0
	resolved_enemy_targets = 0
	total_enemy_targets = 0
	is_cleared = false
	is_failed = false
	is_paused = false
	get_tree().paused = false
	result_panel.visible = false
	pause_panel.visible = false
	result_title_label.text = ""
	result_body_label.text = ""
	pause_hint_label.visible = true
	_on_player_health_changed(player.current_health, player.max_health)
	_connect_clear_targets()


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP: %d/%d" % [current_health, max_health]


func _on_player_defeated() -> void:
	is_failed = true
	_set_gameplay_active(false)
	_show_result("RUN FAILED", "Result: Failed")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE:
		if is_failed or is_cleared:
			return
		if is_paused:
			_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()
		return

	if not (is_failed or is_cleared):
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		get_tree().paused = false
		get_tree().call_deferred("reload_current_scene")


func _connect_clear_targets() -> void:
	var clear_targets := get_tree().get_nodes_in_group("clear_targets")
	total_enemy_targets = clear_targets.size()

	for clear_target in clear_targets:
		if clear_target.has_signal("resolved"):
			clear_target.resolved.connect(_on_clear_target_resolved)


func _on_clear_target_resolved(by_player: bool) -> void:
	if is_failed or is_cleared:
		return

	resolved_enemy_targets += 1
	if by_player:
		cleared_enemy_targets += 1

	if resolved_enemy_targets >= total_enemy_targets and total_enemy_targets > 0:
		_on_stage_cleared()


func _on_stage_cleared() -> void:
	is_cleared = true
	player.set_controls_enabled(false)
	_set_gameplay_active(false)
	_show_result("RUN CLEARED", "Result: Cleared")


func _set_gameplay_active(active: bool) -> void:
	for clear_target in get_tree().get_nodes_in_group("clear_targets"):
		if clear_target.has_method("set_gameplay_active"):
			clear_target.set_gameplay_active(active)

	for hazard in get_tree().get_nodes_in_group("hazards"):
		if hazard.has_method("set_gameplay_active"):
			hazard.set_gameplay_active(active)


func _show_result(title: String, outcome_text: String) -> void:
	var summary_text := "Summary: You completed the current single-run demo."
	if is_failed:
		summary_text = "Summary: Your ship was lost before the run was cleared."

	if is_paused:
		_resume_game()

	result_title_label.text = title
	result_body_label.text = "\n".join([
		outcome_text,
		"Destroyed: %d/%d" % [cleared_enemy_targets, total_enemy_targets],
		summary_text,
		"Now: Press R to play again",
		"Next: More route choices are planned in a later stage",
		"Build: This version now supports one complete demo run",
	])
	result_panel.visible = true


func _pause_game() -> void:
	is_paused = true
	pause_panel.visible = true
	get_tree().paused = true
	continue_button.grab_focus()


func _resume_game() -> void:
	get_tree().paused = false
	is_paused = false
	pause_panel.visible = false


func _on_continue_button_pressed() -> void:
	_resume_game()


func _on_back_to_menu_button_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
