extends Node2D

const RUN_RESULT_SCENE_PATH := "res://scenes/run_result.tscn"
const BUILD_LABEL := "Build: Showcase Build 0.17"

@onready var player := $Player
@onready var health_label := $HUD/HealthLabel as Label
@onready var pause_hint_label := $HUD/PauseHintLabel as Label
@onready var guide_panel := $HUD/GuidePanel as PanelContainer
@onready var guide_timer := $HUD/GuideTimer as Timer
@onready var pause_panel := $HUD/PausePanel as PanelContainer
@onready var continue_button := $HUD/PausePanel/MarginContainer/Content/ContinueButton as Button
@onready var back_to_menu_button := $HUD/PausePanel/MarginContainer/Content/BackToMenuButton as Button

var cleared_enemy_targets := 0
var resolved_enemy_targets := 0
var total_enemy_targets := 0
var is_cleared := false
var is_failed := false
var is_paused := false
var guidance_hidden := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)
	continue_button.pressed.connect(_on_continue_button_pressed)
	back_to_menu_button.pressed.connect(_on_back_to_menu_button_pressed)
	guide_timer.timeout.connect(_on_guide_timer_timeout)

	cleared_enemy_targets = 0
	resolved_enemy_targets = 0
	total_enemy_targets = 0
	is_cleared = false
	is_failed = false
	is_paused = false
	guidance_hidden = false
	get_tree().paused = false
	pause_panel.visible = false
	pause_hint_label.visible = true
	guide_panel.visible = true
	guide_timer.start()
	_on_player_health_changed(player.current_health, player.max_health)
	_connect_clear_targets()


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP: %d/%d" % [current_health, max_health]


func _on_player_defeated() -> void:
	is_failed = true
	_set_gameplay_active(false)
	_go_to_result_screen("RUN FAILED", "Status: Failed")


func _unhandled_input(event: InputEvent) -> void:
	if _is_guidance_trigger_event(event):
		_hide_guide_panel()

	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE:
		if is_failed or is_cleared:
			return
		if is_paused:
			_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()
		return


func _is_guidance_trigger_event(event: InputEvent) -> bool:
	if guidance_hidden:
		return false
	if event is not InputEventKey:
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return false
	return key_event.physical_keycode in [
		KEY_W,
		KEY_A,
		KEY_S,
		KEY_D,
		KEY_UP,
		KEY_DOWN,
		KEY_LEFT,
		KEY_RIGHT,
		KEY_SPACE,
		KEY_ENTER,
		KEY_KP_ENTER,
		KEY_ESCAPE,
	]


func _hide_guide_panel() -> void:
	if guidance_hidden:
		return
	guidance_hidden = true
	guide_panel.visible = false
	guide_timer.stop()


func _on_guide_timer_timeout() -> void:
	_hide_guide_panel()

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
	_go_to_result_screen("RUN CLEARED", "Status: Cleared")


func _set_gameplay_active(active: bool) -> void:
	for clear_target in get_tree().get_nodes_in_group("clear_targets"):
		if clear_target.has_method("set_gameplay_active"):
			clear_target.set_gameplay_active(active)

	for hazard in get_tree().get_nodes_in_group("hazards"):
		if hazard.has_method("set_gameplay_active"):
			hazard.set_gameplay_active(active)


func _go_to_result_screen(title: String, outcome_text: String) -> void:
	var summary_text := "Summary: You completed the current single-run demo."
	if is_failed:
		summary_text = "Summary: Your ship was lost before the run was cleared."

	if is_paused:
		_resume_game()

	RunResultState.store_result(
		title,
		outcome_text,
		cleared_enemy_targets,
		total_enemy_targets,
		summary_text,
		BUILD_LABEL
	)
	get_tree().change_scene_to_file(RUN_RESULT_SCENE_PATH)


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
