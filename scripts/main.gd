extends Node2D

const RUN_RESULT_SCENE_PATH := "res://scenes/run_result.tscn"
const BUILD_LABEL := "版本：展示版本 0.17"
const ENEMY_TARGET_SCENE := preload("res://scenes/enemy_target.tscn")
const OBSTACLE_SCENE := preload("res://scenes/obstacle.tscn")
const CHAIN_WINDOW_SECONDS := 1.35
const CHAIN_BONUS_STEP := 35
const CHAIN_BONUS_CAP := 280
const WAVE_CLEAR_BONUS_BASE := 160
const PERFECT_WAVE_BONUS := 260

@onready var player := $Player
@onready var health_label := $HUD/HealthLabel as Label
@onready var pause_hint_label := $HUD/PauseHintLabel as Label
@onready var hud_layer := $HUD as CanvasLayer
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
var current_wave_number := 1
var active_wave_targets := 0
var resolved_wave_targets := 0
var cleared_wave_targets := 0
var wave_specs: Array[Dictionary] = []
var status_label: Label
var score_label: Label
var score := 0
var chain_count := 0
var best_chain := 0
var chain_bonus_score := 0
var chain_timer := 0.0
var score_notice := ""
var score_notice_timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	wave_specs = _build_wave_specs()

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
	_build_status_label()
	_apply_chinese_labels()
	guide_timer.start()
	_on_player_health_changed(player.current_health, player.max_health)
	_connect_clear_targets()


func _process(delta: float) -> void:
	if is_failed or is_cleared:
		return
	if chain_timer > 0.0:
		chain_timer = maxf(chain_timer - delta, 0.0)
		if chain_timer <= 0.0:
			chain_count = 0
			_update_score_label()
	if score_notice_timer > 0.0:
		score_notice_timer = maxf(score_notice_timer - delta, 0.0)
		if score_notice_timer <= 0.0:
			score_notice = ""
			_update_score_label()


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "生命：%d/%d" % [current_health, max_health]
	_update_status_label()


func _on_player_defeated() -> void:
	is_failed = true
	_set_gameplay_active(false)
	_go_to_result_screen("任务失败", "状态：失败")


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
	current_wave_number = 1
	active_wave_targets = clear_targets.size()
	resolved_wave_targets = 0
	cleared_wave_targets = 0
	total_enemy_targets = active_wave_targets + _planned_scripted_target_count()
	score = 0
	chain_count = 0
	best_chain = 0
	chain_bonus_score = 0
	chain_timer = 0.0

	for clear_target in clear_targets:
		_register_clear_target(clear_target)

	_update_status_label()
	_update_score_label()


func _register_clear_target(clear_target: Node) -> void:
	if not clear_target.has_signal("resolved"):
		return
	var callback := Callable(self, "_on_clear_target_resolved").bind(clear_target)
	if not clear_target.resolved.is_connected(callback):
		clear_target.resolved.connect(callback)


func _on_clear_target_resolved(by_player: bool, clear_target: Node) -> void:
	if is_failed or is_cleared:
		return

	resolved_enemy_targets += 1
	if by_player:
		cleared_enemy_targets += 1
		cleared_wave_targets += 1
		_award_target_score(clear_target)

	resolved_wave_targets += 1
	_update_status_label()

	if resolved_wave_targets >= active_wave_targets and active_wave_targets > 0:
		_award_wave_clear_bonus()
		_advance_or_clear_stage()


func _advance_or_clear_stage() -> void:
	if current_wave_number <= wave_specs.size():
		current_wave_number += 1
		_spawn_scripted_wave()
		return

	_on_stage_cleared()


func _on_stage_cleared() -> void:
	is_cleared = true
	player.set_controls_enabled(false)
	_set_gameplay_active(false)
	_go_to_result_screen("任务完成", "状态：已清除")


func _set_gameplay_active(active: bool) -> void:
	for clear_target in get_tree().get_nodes_in_group("clear_targets"):
		if clear_target.has_method("set_gameplay_active"):
			clear_target.set_gameplay_active(active)

	for hazard in get_tree().get_nodes_in_group("hazards"):
		if hazard.has_method("set_gameplay_active"):
			hazard.set_gameplay_active(active)


func _go_to_result_screen(title: String, outcome_text: String) -> void:
	var accuracy := 0
	if total_enemy_targets > 0:
		accuracy = int(round(float(cleared_enemy_targets) / float(total_enemy_targets) * 100.0))
	var summary_text := "试玩总结：完成 %d 波清除路线，目标清除率 %d%%。" % [current_wave_number, accuracy]
	if is_failed:
		summary_text = "试玩总结：战机在第 %d 波被击毁，目标清除率 %d%%，最高连击 x%d。" % [current_wave_number, accuracy, best_chain]
	else:
		summary_text = "%s 最高连击 x%d，连击奖励 %d 分。" % [summary_text, best_chain, chain_bonus_score]

	if is_paused:
		_resume_game()

	RunResultState.store_result(
		title,
		outcome_text,
		cleared_enemy_targets,
		total_enemy_targets,
		summary_text,
		BUILD_LABEL,
		score,
		best_chain,
		chain_bonus_score
	)
	get_tree().change_scene_to_file(RUN_RESULT_SCENE_PATH)


func _apply_chinese_labels() -> void:
	pause_hint_label.text = "Esc：暂停"
	$HUD/GuidePanel/MarginContainer/Content/GuideTitle.text = "试玩提示"
	$HUD/GuidePanel/MarginContainer/Content/GuideBody.text = "移动：WASD 或方向键\n射击：Space 或 Enter\n目标：完成 3 波清除路线\n暂停：Esc"
	$HUD/GuidePanel/MarginContainer/Content/GuideHint.text = "这个提示会在片刻后淡出，也会在首次操作后隐藏。"
	$HUD/PausePanel/MarginContainer/Content/PauseTitle.text = "试玩暂停"
	$HUD/PausePanel/MarginContainer/Content/PauseBody.text = "继续当前路线，或返回主菜单。"
	continue_button.text = "继续试玩"
	back_to_menu_button.text = "返回菜单"


func _build_status_label() -> void:
	status_label = Label.new()
	status_label.name = "RouteStatusLabel"
	status_label.offset_left = 18.0
	status_label.offset_top = 48.0
	status_label.offset_right = 520.0
	status_label.offset_bottom = 76.0
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color(0.76, 0.86, 1.0))
	hud_layer.add_child(status_label)

	score_label = Label.new()
	score_label.name = "ScoreChainLabel"
	score_label.offset_left = 18.0
	score_label.offset_top = 76.0
	score_label.offset_right = 620.0
	score_label.offset_bottom = 104.0
	score_label.add_theme_font_size_override("font_size", 16)
	score_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	hud_layer.add_child(score_label)


func _update_status_label() -> void:
	if status_label == null:
		return
	status_label.text = "波次 %d/%d   清除 %d/%d   本波 %d/%d" % [
		current_wave_number,
		wave_specs.size() + 1,
		cleared_enemy_targets,
		total_enemy_targets,
		min(resolved_wave_targets, active_wave_targets),
		active_wave_targets,
	]


func _update_score_label() -> void:
	if score_label == null:
		return
	var chain_text := "连击 x%d" % chain_count if chain_count >= 2 else "连击待机"
	var notice_text := "   %s" % score_notice if not score_notice.is_empty() else ""
	score_label.text = "分数 %06d   %s   最高 x%d%s" % [
		score,
		chain_text,
		best_chain,
		notice_text,
	]


func _build_wave_specs() -> Array[Dictionary]:
	return [
		{
			"title": "第二波：横向列阵",
			"targets": [
				{"x": 180.0, "y": -40.0, "speed": 128.0, "horizontal_drift": 34.0, "drift_phase": 0.0},
				{"x": 340.0, "y": -86.0, "speed": 132.0, "horizontal_drift": 42.0, "drift_phase": 1.2},
				{"x": 500.0, "y": -52.0, "speed": 126.0, "horizontal_drift": 34.0, "drift_phase": 2.4},
				{"x": 660.0, "y": -98.0, "speed": 132.0, "horizontal_drift": 42.0, "drift_phase": 3.6},
				{"x": 820.0, "y": -58.0, "speed": 128.0, "horizontal_drift": 34.0, "drift_phase": 4.8},
			],
			"obstacles": [
				{"x": 270.0, "y": -150.0, "speed": 170.0, "horizontal_drift": 32.0},
				{"x": 690.0, "y": -210.0, "speed": 180.0, "horizontal_drift": 38.0},
			],
		},
		{
			"title": "第三波：装甲目标",
			"targets": [
				{"x": 240.0, "y": -44.0, "speed": 142.0, "hit_points": 2, "horizontal_drift": 38.0, "drift_phase": 0.4},
				{"x": 480.0, "y": -92.0, "speed": 118.0, "hit_points": 3, "horizontal_drift": 58.0, "drift_frequency": 1.7, "drift_phase": 1.8},
				{"x": 720.0, "y": -44.0, "speed": 142.0, "hit_points": 2, "horizontal_drift": 38.0, "drift_phase": 3.2},
				{"x": 360.0, "y": -190.0, "speed": 150.0, "hit_points": 1, "horizontal_drift": 26.0, "drift_phase": 2.4},
				{"x": 600.0, "y": -190.0, "speed": 150.0, "hit_points": 1, "horizontal_drift": 26.0, "drift_phase": 4.2},
			],
			"obstacles": [
				{"x": 160.0, "y": -140.0, "speed": 192.0, "horizontal_drift": 24.0},
				{"x": 480.0, "y": -240.0, "speed": 210.0, "horizontal_drift": 58.0},
				{"x": 800.0, "y": -180.0, "speed": 196.0, "horizontal_drift": 28.0},
			],
		},
	]


func _planned_scripted_target_count() -> int:
	var count := 0
	for wave in wave_specs:
		var targets: Array = wave.get("targets", [])
		count += targets.size()
	return count


func _spawn_scripted_wave() -> void:
	var spec_index := current_wave_number - 2
	if spec_index < 0 or spec_index >= wave_specs.size():
		_on_stage_cleared()
		return

	var spec := wave_specs[spec_index]
	active_wave_targets = 0
	resolved_wave_targets = 0
	cleared_wave_targets = 0
	_update_status_label()
	_update_score_label()

	for target_config in spec.get("targets", []):
		_spawn_target(target_config)
	for obstacle_config in spec.get("obstacles", []):
		_spawn_obstacle(obstacle_config)

	var title := String(spec.get("title", "下一波目标"))
	_show_wave_banner(title)
	_update_status_label()


func _spawn_target(config: Dictionary) -> void:
	var target := ENEMY_TARGET_SCENE.instantiate()
	target.global_position = Vector2(float(config.get("x", 480.0)), float(config.get("y", -48.0)))
	if target.has_method("configure"):
		target.configure(config)
	add_child(target)
	_register_clear_target(target)
	active_wave_targets += 1


func _spawn_obstacle(config: Dictionary) -> void:
	var obstacle := OBSTACLE_SCENE.instantiate()
	obstacle.global_position = Vector2(float(config.get("x", 480.0)), float(config.get("y", -96.0)))
	if obstacle.has_method("configure"):
		obstacle.configure(config)
	add_child(obstacle)


func _show_wave_banner(text: String) -> void:
	if guide_panel.visible:
		return
	guide_panel.visible = true
	$HUD/GuidePanel/MarginContainer/Content/GuideTitle.text = text
	$HUD/GuidePanel/MarginContainer/Content/GuideBody.text = "敌阵正在推进。优先清除装甲目标，绕开漂移障碍。"
	$HUD/GuidePanel/MarginContainer/Content/GuideHint.text = "继续移动或射击即可隐藏提示。"
	guidance_hidden = false
	guide_timer.start(2.2)


func _award_target_score(clear_target: Node) -> void:
	var base_score := 100
	if clear_target != null and clear_target.has_method("get_clear_score"):
		base_score = int(clear_target.call("get_clear_score"))

	var bonus := _register_chain_bonus()
	score += base_score + bonus
	if bonus > 0:
		score_notice = "击破 +%d / 连击 +%d" % [base_score, bonus]
	else:
		score_notice = "击破 +%d" % base_score
	score_notice_timer = 1.15
	_update_score_label()


func _register_chain_bonus() -> int:
	if chain_timer > 0.0:
		chain_count += 1
	else:
		chain_count = 1
	chain_timer = CHAIN_WINDOW_SECONDS
	best_chain = maxi(best_chain, chain_count)
	if chain_count < 3:
		return 0

	var bonus := mini((chain_count - 2) * CHAIN_BONUS_STEP, CHAIN_BONUS_CAP)
	chain_bonus_score += bonus
	return bonus


func _award_wave_clear_bonus() -> void:
	var wave_bonus := WAVE_CLEAR_BONUS_BASE * current_wave_number
	if cleared_wave_targets >= active_wave_targets:
		wave_bonus += PERFECT_WAVE_BONUS
	score += wave_bonus
	score_notice = "波次奖励 +%d" % wave_bonus
	score_notice_timer = 1.45
	_update_score_label()


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
