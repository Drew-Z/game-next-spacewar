extends CharacterBody2D

const FIRE_COOLDOWN := 0.18
const VIEWPORT_MARGIN := 20.0

@export var speed := 320.0
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

var fire_cooldown_remaining := 0.0


func _physics_process(delta: float) -> void:
	fire_cooldown_remaining = maxf(0.0, fire_cooldown_remaining - delta)

	velocity = _get_move_input() * speed
	move_and_slide()
	_clamp_to_viewport()

	if _is_shoot_pressed():
		_try_fire()


func _get_move_input() -> Vector2:
	var x := 0.0
	var y := 0.0

	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		y += 1.0

	return Vector2(x, y).normalized()


func _is_shoot_pressed() -> bool:
	return Input.is_physical_key_pressed(KEY_SPACE) or Input.is_action_pressed("ui_accept")


func _try_fire() -> void:
	if fire_cooldown_remaining > 0.0:
		return

	fire_cooldown_remaining = FIRE_COOLDOWN

	var bullet := bullet_scene.instantiate() as Node2D
	bullet.global_position = global_position + Vector2(0, -28)
	get_tree().current_scene.add_child(bullet)


func _clamp_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	global_position.x = clampf(global_position.x, VIEWPORT_MARGIN, viewport_size.x - VIEWPORT_MARGIN)
	global_position.y = clampf(global_position.y, VIEWPORT_MARGIN, viewport_size.y - VIEWPORT_MARGIN)
