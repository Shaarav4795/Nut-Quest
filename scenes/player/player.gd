extends CharacterBody2D

signal died
signal landed

@export var gravity := 2300.0
@export var charge_accel := 3500.0
@export var max_fall := 1800.0
@export var idle_fall_cap := 900.0

@export var bounce_boost := 1.85
@export var bounce_natural := 0.99
@export var min_bounce := 390.0
@export var max_bounce := 1390.0

@export var air_steer := 900.0
@export var max_side := 420.0

@export var spin_speed := 25.0

@onready var sprite: Sprite2D = $Sprite

var _spawn_point := Vector2.ZERO
var _spin_dir := 1
var _held := false
var _hold_on_respawn := false
var _launching := false
var _dead := false
var revived_count := 0


func _ready() -> void:
	_spawn_point = position


func is_held() -> bool:
	return _held


func is_launching() -> bool:
	return _launching


func die() -> void:
	if _dead:
		return
	if died.get_connections().is_empty():
		respawn()
		return
	_dead = true
	velocity = Vector2.ZERO
	died.emit()


func revive() -> void:
	_dead = false
	revived_count += 1
	respawn()


func hold(point: Vector2) -> void:
	global_position = point
	velocity = Vector2.ZERO
	_spin_dir = 1
	_held = true
	_hold_on_respawn = true
	_launching = false
	sprite.rotation = 0.0
	sprite.offset = Vector2.ZERO


func release_hold() -> void:
	_held = false
	_hold_on_respawn = false


func launch_to(target: Vector2, flight_time: float) -> void:
	var t := maxf(flight_time, 0.05)
	var d := target - global_position
	velocity = Vector2(d.x / t, d.y / t - 0.5 * gravity * t)
	_held = false
	_launching = true


func respawn() -> void:
	position = _spawn_point
	velocity = Vector2.ZERO
	_spin_dir = 1
	sprite.rotation = 0.0
	sprite.offset = Vector2.ZERO
	_launching = false
	_held = _hold_on_respawn


func _physics_process(delta: float) -> void:
	if _dead or _held:
		return

	if _launching:
		velocity.y += gravity * delta
		move_and_slide()
		_roll(signf(velocity.x), delta)
		if is_on_floor():
			_launching = false
			velocity = Vector2.ZERO
			landed.emit()
		return

	var charging := Input.is_action_pressed("charge_down")
	var dir := Input.get_axis("move_left", "move_right")

	if charging:
		velocity.y = minf(velocity.y + charge_accel * delta, max_fall)
	else:
		velocity.y = minf(velocity.y + gravity * delta, idle_fall_cap)

	velocity.x = move_toward(velocity.x, dir * max_side, air_steer * delta)

	var impact_speed := velocity.y

	move_and_slide()

	if is_on_floor() and impact_speed >= 0.0:
		var restitution := bounce_boost if charging else bounce_natural
		velocity.y = -clampf(impact_speed * restitution, min_bounce, max_bounce)

	if dir != 0.0:
		_roll(dir, delta)
	else:
		_unwind(delta)


func _roll(dir: float, delta: float) -> void:
	if dir > 0.0:
		_spin_dir = 1
		sprite.rotation += spin_speed * delta
		sprite.flip_h = false
	elif dir < 0.0:
		_spin_dir = -1
		sprite.rotation -= spin_speed * delta
		sprite.flip_h = true


func _unwind(delta: float) -> void:
	var turns := sprite.rotation / TAU
	var target := (ceilf(turns) if _spin_dir > 0 else floorf(turns)) * TAU
	sprite.rotation = move_toward(sprite.rotation, target, spin_speed * delta)
	if is_equal_approx(sprite.rotation, target):
		sprite.rotation = 0.0
