extends Node2D

@onready var player := $Player
@onready var health_label := $HUD/HealthLabel as Label
@onready var fail_label := $HUD/FailLabel as Label


func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)

	fail_label.visible = false
	_on_player_health_changed(player.current_health, player.max_health)


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP: %d/%d" % [current_health, max_health]


func _on_player_defeated() -> void:
	fail_label.visible = true
