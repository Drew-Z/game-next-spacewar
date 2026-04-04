extends Node2D

@onready var player := $Player
@onready var health_label := $HUD/HealthLabel as Label
@onready var fail_label := $HUD/FailLabel as Label

var is_failed := false


func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)

	is_failed = false
	fail_label.visible = false
	_on_player_health_changed(player.current_health, player.max_health)


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP: %d/%d" % [current_health, max_health]


func _on_player_defeated() -> void:
	is_failed = true
	fail_label.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not is_failed:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		get_tree().call_deferred("reload_current_scene")
