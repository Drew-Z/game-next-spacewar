extends Area2D

@export var speed := 700.0


func _process(delta: float) -> void:
	global_position += Vector2.UP * speed * delta

	var viewport_size := get_viewport_rect().size
	if global_position.y < -24.0:
		queue_free()
		return
	if global_position.x < -24.0 or global_position.x > viewport_size.x + 24.0:
		queue_free()
