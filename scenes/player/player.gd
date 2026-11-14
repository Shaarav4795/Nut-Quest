extends CharacterBody2D

@export var gravity := 1900.0
@export var charge_accel := 3200.0
@export var max_fall := 1800.0
@export var idle_fall_cap := 900.0

@export var bounce_boost := 1.18
@export var bounce_natural := 0.82
@export var min_bounce := 260.0
@export var max_bounce := 1600.0

@export var air_steer := 900.0
@export var max_side := 420.0

@onready var sprite: Sprite2D = $Sprite


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
		var launch := impact_speed * restitution
		if launch < min_bounce:
			velocity.y = 0.0
		else:
			velocity.y = -minf(launch, max_bounce)

	if dir != 0.0:
		sprite.flip_h = dir < 0.0
