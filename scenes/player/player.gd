extends CharacterBody2D

@export var gravity := 2300.0
@export var charge_accel := 3500.0
@export var max_fall := 1800.0
@export var idle_fall_cap := 900.0

@export var bounce_boost := 1.18
@export var bounce_natural := 0.87
@export var min_bounce := 500.0
@export var max_bounce := 1300.0

@export var air_steer := 900.0
@export var max_side := 420.0

@export var spin_speed := 9.0

@onready var sprite: Sprite2D = $Sprite

var _spawn_point := Vector2.ZERO

var _spin_dir := 1


func _ready() -> void:
	_spawn_point = position


func respawn() -> void:
	position = _spawn_point
	velocity = Vector2.ZERO
	_spin_dir = 1
	sprite.rotation = 0.0


func _physics_process(delta: float) -> void:
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


	if dir > 0.0:
		_spin_dir = 1
		sprite.rotation += spin_speed * delta
		sprite.flip_h = false
	elif dir < 0.0:
		_spin_dir = -1
		sprite.rotation -= spin_speed * delta
		sprite.flip_h = true
	else:
		var turns := sprite.rotation / TAU
		var target := (ceilf(turns) if _spin_dir > 0 else floorf(turns)) * TAU
		sprite.rotation = move_toward(sprite.rotation, target, spin_speed * delta)
		if is_equal_approx(sprite.rotation, target):
			sprite.rotation = 0.0
