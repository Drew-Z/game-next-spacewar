extends Area2D

signal resolved(by_player: bool)

@export var speed := 110.0
@export var hit_points := 1
@export var horizontal_drift := 0.0
@export var drift_frequency := 1.35
@export var drift_phase := 0.0

var gameplay_active := true
var is_destroyed := false
var is_resolved := false
var max_hit_points := 1
var base_x := 0.0
var elapsed := 0.0


func _ready() -> void:
	add_to_group("clear_targets")
	max_hit_points = maxi(hit_points, 1)
	base_x = global_position.x
	_apply_health_visual()
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if is_destroyed or not gameplay_active:
		return

	elapsed += delta
	global_position.y += speed * delta
	if horizontal_drift > 0.0:
		global_position.x = base_x + sin(elapsed * drift_frequency + drift_phase) * horizontal_drift

	var viewport_size := get_viewport_rect().size
	if global_position.y > viewport_size.y + 40.0:
		_resolve(false)
		queue_free()


func configure(config: Dictionary) -> void:
	speed = float(config.get("speed", speed))
	hit_points = maxi(int(config.get("hit_points", hit_points)), 1)
	max_hit_points = hit_points
	horizontal_drift = float(config.get("horizontal_drift", horizontal_drift))
	drift_frequency = float(config.get("drift_frequency", drift_frequency))
	drift_phase = float(config.get("drift_phase", drift_phase))
	base_x = global_position.x
	_apply_health_visual()


func hit() -> void:
	if is_destroyed:
		return

	hit_points -= 1
	if hit_points > 0:
		_flash_hit()
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


func _flash_hit() -> void:
	var body := $Body as Polygon2D
	body.color = Color(1.0, 0.82, 0.40, 1.0)
	scale = Vector2(1.10, 1.10)
	await get_tree().create_timer(0.06).timeout
	if is_instance_valid(self) and not is_destroyed:
		scale = Vector2.ONE
		_apply_health_visual()


func get_clear_score() -> int:
	var armor_bonus := maxi(max_hit_points - 1, 0) * 45
	var speed_bonus := maxi(int(round((speed - 110.0) / 12.0)), 0) * 8
	var drift_bonus := maxi(int(round(horizontal_drift / 20.0)), 0) * 10
	return 100 + armor_bonus + speed_bonus + drift_bonus


func _apply_health_visual() -> void:
	if not is_node_ready():
		return
	var body := $Body as Polygon2D
	var ratio := float(hit_points) / float(maxi(max_hit_points, 1))
	if max_hit_points >= 3:
		body.color = Color(0.98, 0.56 + 0.20 * ratio, 0.36, 1.0)
	elif max_hit_points == 2:
		body.color = Color(0.75, 0.92, 1.0, 1.0)
	else:
		body.color = Color(0.52, 0.74, 1.0, 1.0)
