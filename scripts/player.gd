extends CharacterBody2D

const FIRE_COOLDOWN := 0.18
const DAMAGE_COOLDOWN := 0.45
const VIEWPORT_MARGIN := 20.0
const NORMAL_COLOR := Color(0.454902, 0.847059, 1, 1)
const HURT_COLOR := Color(1, 0.568627, 0.568627, 1)
const DEFEATED_COLOR := Color(0.631373, 0.247059, 0.247059, 1)

signal health_changed(current_health: int, max_health: int)
signal defeated

@export var speed := 320.0
@export var max_health := 3
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

@onready var body_visual := $Body as Polygon2D
@onready var collision_shape := $CollisionShape2D as CollisionShape2D

var current_health := 0
var is_defeated := false
var damage_cooldown_remaining := 0.0
var fire_cooldown_remaining := 0.0


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func _physics_process(delta: float) -> void:
	damage_cooldown_remaining = maxf(0.0, damage_cooldown_remaining - delta)
	fire_cooldown_remaining = maxf(0.0, fire_cooldown_remaining - delta)
	_update_visual_state()

	if is_defeated:
		velocity = Vector2.ZERO
		return

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


func take_damage(amount: int = 1) -> void:
	if is_defeated or damage_cooldown_remaining > 0.0:
		return

	current_health = maxi(0, current_health - amount)
	damage_cooldown_remaining = DAMAGE_COOLDOWN
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		is_defeated = true
		collision_shape.set_deferred("disabled", true)
		defeated.emit()

	_update_visual_state()


func _clamp_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	global_position.x = clampf(global_position.x, VIEWPORT_MARGIN, viewport_size.x - VIEWPORT_MARGIN)
	global_position.y = clampf(global_position.y, VIEWPORT_MARGIN, viewport_size.y - VIEWPORT_MARGIN)


func _update_visual_state() -> void:
	if is_defeated:
		body_visual.color = DEFEATED_COLOR
	elif damage_cooldown_remaining > 0.0:
		body_visual.color = HURT_COLOR
	else:
		body_visual.color = NORMAL_COLOR
