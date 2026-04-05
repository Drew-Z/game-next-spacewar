extends Area2D

signal resolved(by_player: bool)

@export var speed := 110.0

var gameplay_active := true
var is_destroyed := false
var is_resolved := false


func _ready() -> void:
	add_to_group("clear_targets")
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if is_destroyed or not gameplay_active:
		return

	global_position += Vector2.DOWN * speed * delta

	var viewport_size := get_viewport_rect().size
	if global_position.y > viewport_size.y + 40.0:
		_resolve(false)
		queue_free()


func hit() -> void:
	if is_destroyed:
		return

	is_destroyed = true
	_resolve(true)
	monitoring = false
	monitorable = false

	var body := $Body as Polygon2D
	body.color = Color(1, 0.901961, 0.509804, 1)
	scale = Vector2(1.2, 1.2)

	await get_tree().create_timer(0.08).timeout
	queue_free()


func set_gameplay_active(active: bool) -> void:
	gameplay_active = active
	if is_destroyed:
		return
	monitoring = active
	monitorable = active


func _on_body_entered(body: Node2D) -> void:
	if is_destroyed or not gameplay_active:
		return
	if body.has_method("take_damage"):
		body.take_damage(1)
		hit()


func _resolve(by_player: bool) -> void:
	if is_resolved:
		return
	is_resolved = true
	emit_signal("resolved", by_player)
