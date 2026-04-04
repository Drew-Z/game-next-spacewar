extends Area2D

@export var speed := 110.0

var is_destroyed := false


func _process(delta: float) -> void:
	if is_destroyed:
		return

	global_position += Vector2.DOWN * speed * delta

	var viewport_size := get_viewport_rect().size
	if global_position.y > viewport_size.y + 40.0:
		queue_free()


func hit() -> void:
	if is_destroyed:
		return

	is_destroyed = true
	monitoring = false
	monitorable = false

	var body := $Body as Polygon2D
	body.color = Color(1, 0.901961, 0.509804, 1)
	scale = Vector2(1.2, 1.2)

	await get_tree().create_timer(0.08).timeout
	queue_free()
