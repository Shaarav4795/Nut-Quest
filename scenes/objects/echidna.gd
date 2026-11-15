extends CharacterBody2D

@export_group("Movement")
@export var walk_speed := 70.0
@export var ground_accel := 700.0
@export var gravity := 1400.0

@export_group("Patrol")
@export var patrol_left := -140.0
@export var patrol_right := 140.0

@export_group("Timing")
@export var min_walk_time := 0.8
@export var max_walk_time := 2.5
@export var min_idle_time := 0.5
@export var max_idle_time := 2.0

@export_group("Art")
@export var stand_texture: Texture2D = preload("res://assets/squirrel/hedge_stand.png")
@export var walk_frame_a: Texture2D = preload("res://assets/squirrel/hedge_walk_1.png")
@export var walk_frame_b: Texture2D = preload("res://assets/squirrel/hedge_walk_2.png")
@export var walk_frame_time := 0.16

@onready var sprite: Sprite2D = $Sprite
@onready var ledge_check: RayCast2D = $LedgeCheck
@onready var hurtbox: Area2D = $Hurtbox

enum State { IDLE, WALK }

var _state: State = State.IDLE
var _timer := 0.0
var _dir := 1
var _home_x := 0.0
var _frame := 0
var _frame_timer := 0.0


func _ready() -> void:
	_home_x = global_position.x
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	_enter(State.IDLE)


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	_timer -= delta
	if _timer <= 0.0:
		_enter(State.IDLE if _state == State.WALK else State.WALK)

	if _state == State.WALK:
		var offset_x := global_position.x - _home_x
		if (offset_x <= patrol_left and _dir < 0) or (offset_x >= patrol_right and _dir > 0):
			_dir = -_dir
		if is_on_wall():
			_dir = -_dir
		if not _ground_ahead():
			_dir = -_dir
		velocity.x = move_toward(velocity.x, _dir * walk_speed, ground_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, ground_accel * delta)

	move_and_slide()

	sprite.flip_h = _dir > 0.0

	if _state == State.WALK:
		_frame_timer += delta
		if _frame_timer >= walk_frame_time:
			_frame_timer -= walk_frame_time
			_frame = 1 - _frame
			sprite.texture = walk_frame_a if _frame == 0 else walk_frame_b


func _ground_ahead() -> bool:
	ledge_check.position.x = _dir * 34.0
	ledge_check.force_raycast_update()
	return ledge_check.is_colliding()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
	elif body.has_method("respawn"):
		body.respawn()


func _enter(next: State) -> void:
	_state = next
	if _state == State.WALK:
		_dir = 1 if randf() < 0.5 else -1
		_timer = randf_range(min_walk_time, max_walk_time)
		_frame = 0
		_frame_timer = 0.0
		sprite.texture = walk_frame_a
	else:
		_timer = randf_range(min_idle_time, max_idle_time)
		sprite.texture = stand_texture
