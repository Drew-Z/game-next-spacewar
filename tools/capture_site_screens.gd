extends SceneTree

const OUTPUT_DIR := "D:/workspace4Cursor/game/blog/public/images/projects"
const OUTPUT_PREFIX := "next-spacewar"
const MENU_SCENE := "res://scenes/main_menu.tscn"
const BATTLE_SCENE := "res://scenes/main.tscn"
const RESULT_SCENE := "res://scenes/run_result.tscn"
const RunResultState := preload("res://scripts/run_result_state.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var mkdir_error := DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	if mkdir_error != OK and mkdir_error != ERR_ALREADY_EXISTS:
		push_error("Failed to create screenshot output dir: %s" % mkdir_error)
		quit(1)
		return

	root.size = Vector2i(960, 540)
	await _capture_menu()
	await _capture_battle()
	await _capture_result()
	quit()


func _capture_menu() -> void:
	await change_scene_to_file(MENU_SCENE)
	await _settle_frames(16)
	await _save_viewport("%s-menu.png" % OUTPUT_PREFIX)


func _capture_battle() -> void:
	await change_scene_to_file(BATTLE_SCENE)
	await _settle_frames(20)
	var battle := current_scene
	if battle != null:
		_prepare_showcase_battle(battle)
	await _settle_frames(8)
	await _save_viewport("%s-battle.png" % OUTPUT_PREFIX)


func _capture_result() -> void:
	RunResultState.store_result(
		"任务完成",
		"状态：已清除",
		12,
		13,
		"试玩总结：完成 3 波清除路线，目标清除率 92%。最高连击 x7，连击奖励 420 分。",
		"版本：展示版本 0.17",
		9420,
		7,
		420
	)
	await change_scene_to_file(RESULT_SCENE)
	await _settle_frames(20)
	await _save_viewport("%s-result.png" % OUTPUT_PREFIX)


func _prepare_showcase_battle(battle: Node) -> void:
	var guide_panel := battle.get_node_or_null("HUD/GuidePanel")
	if guide_panel != null:
		guide_panel.visible = false
	var guide_timer := battle.get_node_or_null("HUD/GuideTimer")
	if guide_timer != null and guide_timer.has_method("stop"):
		guide_timer.stop()

	battle.set("current_wave_number", 3)
	battle.set("cleared_enemy_targets", 8)
	battle.set("total_enemy_targets", 13)
	battle.set("active_wave_targets", 5)
	battle.set("resolved_wave_targets", 2)
	battle.set("cleared_wave_targets", 2)
	battle.set("score", 7240)
	battle.set("chain_count", 5)
	battle.set("best_chain", 7)
	battle.set("chain_bonus_score", 420)
	battle.set("chain_timer", 1.1)
	battle.set("score_notice", "连击 x5 / 波次奖励待结算")
	battle.set("score_notice_timer", 4.0)

	_configure_existing_targets(battle)
	_configure_existing_obstacles(battle)
	if battle.has_method("_update_status_label"):
		battle.call("_update_status_label")
	if battle.has_method("_update_score_label"):
		battle.call("_update_score_label")
	if battle.has_method("_set_gameplay_active"):
		battle.call("_set_gameplay_active", false)


func _configure_existing_targets(battle: Node) -> void:
	var configs := [
		{"name": "EnemyA", "position": Vector2(210.0, 146.0), "hit_points": 1, "speed": 0.0, "horizontal_drift": 0.0},
		{"name": "EnemyB", "position": Vector2(480.0, 110.0), "hit_points": 3, "speed": 0.0, "horizontal_drift": 0.0},
		{"name": "EnemyC", "position": Vector2(750.0, 170.0), "hit_points": 2, "speed": 0.0, "horizontal_drift": 0.0},
	]
	for config in configs:
		var target := battle.get_node_or_null(String(config["name"]))
		if target == null:
			continue
		target.global_position = Vector2(config["position"])
		if target.has_method("configure"):
			target.configure(config)


func _configure_existing_obstacles(battle: Node) -> void:
	var configs := [
		{"name": "ObstacleA", "position": Vector2(150.0, 242.0), "speed": 0.0, "horizontal_drift": 0.0},
		{"name": "ObstacleB", "position": Vector2(585.0, 214.0), "speed": 0.0, "horizontal_drift": 0.0},
		{"name": "ObstacleC", "position": Vector2(835.0, 270.0), "speed": 0.0, "horizontal_drift": 0.0},
	]
	for config in configs:
		var obstacle := battle.get_node_or_null(String(config["name"]))
		if obstacle == null:
			continue
		obstacle.global_position = Vector2(config["position"])
		if obstacle.has_method("configure"):
			obstacle.configure(config)


func _settle_frames(frame_count: int) -> void:
	for _index in range(frame_count):
		await process_frame


func _save_viewport(file_name: String) -> void:
	await process_frame
	var image := root.get_texture().get_image()
	if image == null:
		push_error("Failed to read viewport image for %s" % file_name)
		return
	var path := "%s/%s" % [OUTPUT_DIR, file_name]
	var error := image.save_png(path)
	if error != OK:
		push_error("Failed to save screenshot %s: %s" % [path, error])
