extends Node2D

@onready var player := $Player
@onready var health_label := $HUD/HealthLabel as Label
@onready var clear_label := $HUD/ClearLabel as Label
@onready var fail_label := $HUD/FailLabel as Label

var cleared_enemy_targets := 0
var total_enemy_targets := 0
var is_cleared := false
var is_failed := false


func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)

	cleared_enemy_targets = 0
	total_enemy_targets = 0
	is_cleared = false
	is_failed = false
	clear_label.visible = false
	fail_label.visible = false
	_on_player_health_changed(player.current_health, player.max_health)
	_connect_clear_targets()


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP: %d/%d" % [current_health, max_health]


func _on_player_defeated() -> void:
	is_failed = true
	_set_gameplay_active(false)
	fail_label.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not is_failed:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		get_tree().call_deferred("reload_current_scene")


func _connect_clear_targets() -> void:
	var clear_targets := get_tree().get_nodes_in_group("clear_targets")
	total_enemy_targets = clear_targets.size()

	for clear_target in clear_targets:
		if clear_target.has_signal("cleared"):
			clear_target.cleared.connect(_on_clear_target_cleared)


func _on_clear_target_cleared() -> void:
	if is_failed or is_cleared:
		return

	cleared_enemy_targets += 1
	if cleared_enemy_targets >= total_enemy_targets and total_enemy_targets > 0:
		_on_stage_cleared()


func _on_stage_cleared() -> void:
	is_cleared = true
	clear_label.visible = true
	player.set_controls_enabled(false)
	_set_gameplay_active(false)


func _set_gameplay_active(active: bool) -> void:
	for clear_target in get_tree().get_nodes_in_group("clear_targets"):
		if clear_target.has_method("set_gameplay_active"):
			clear_target.set_gameplay_active(active)

	for hazard in get_tree().get_nodes_in_group("hazards"):
		if hazard.has_method("set_gameplay_active"):
			hazard.set_gameplay_active(active)
