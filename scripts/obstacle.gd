extends Area2D

@export var speed := 150.0
@export var horizontal_drift := 25.0

var time_passed := 0.0
var is_spent := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if is_spent:
		return

	time_passed += delta
	global_position += Vector2(sin(time_passed) * horizontal_drift, speed) * delta

	var viewport_size := get_viewport_rect().size
	if global_position.y > viewport_size.y + 48.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if is_spent:
		return
	if body.has_method("take_damage"):
		is_spent = true
		body.take_damage(1)
		queue_free()
