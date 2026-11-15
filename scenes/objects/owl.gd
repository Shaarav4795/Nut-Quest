extends CharacterBody2D

@export_group("Flight")
@export var cruise_speed := 220.0
@export var swoop_speed := 540.0
@export var return_speed := 320.0
@export var accel := 900.0
@export var hover_height := 220.0
@export var hold_distance := 110.0

@export_group("Attack")
@export var attack_interval := 2.4
@export var first_attack_delay := 1.2
@export var swoop_duration := 0.8
@export var return_duration := 1.0
@export var swoop_lead := 0.2

@export_group("Art")
@export var dive_texture: Texture2D = preload("res://assets/squirrel/diving.png")
@export var flap_a: Texture2D = preload("res://assets/squirrel/flight1.png")
@export var flap_b: Texture2D = preload("res://assets/squirrel/flight2.png")
@export var flap_c: Texture2D = preload("res://assets/squirrel/flight3.png")
@export var flap_time := 0.11

@onready var sprite: Sprite2D = $Sprite
@onready var hurtbox: Area2D = $Hurtbox

enum State { CRUISE, SWOOP, RETURN }

var _state := State.CRUISE
var _timer := 0.0
var _attack_timer := 0.0
var _frame := 0
var _frame_timer := 0.0
var _dive_dir := Vector2.ZERO
var _dir := 1
var _player: CharacterBody2D = null
var _awake := false


func _ready() -> void:
	_attack_timer = first_attack_delay
	var scene: Node = get_tree().current_scene
	if scene != null:
		_player = scene.find_child("Player", true, false) as CharacterBody2D
	hurtbox.body_entered.connect(_on_touch)
	sprite.texture = flap_a


func is_awake() -> bool:
	return _awake


func _on_touch(body: Node) -> void:
	if body == _player:
		body.call("die")


func _physics_process(delta: float) -> void:
	if _player == null:
		move_and_slide()
		return

	_awake = _player_can_see()
	if not _awake:
		_state = State.CRUISE
		_timer = 0.0
		_attack_timer = first_attack_delay
		velocity = velocity.move_toward(Vector2.ZERO, accel * delta)
		_animate_flap(delta)
		move_and_slide()
		return

	_timer -= delta
	if _state == State.CRUISE:
		_cruise(delta)
	elif _state == State.SWOOP:
		_swoop(delta)
	else:
		_retreat(delta)

	move_and_slide()
	sprite.flip_h = _dir < 0


func _cruise(delta: float) -> void:
	_animate_flap(delta)
	_attack_timer -= delta
	var mark: Vector2 = _player.global_position + Vector2(0, -hover_height)
	var dx: float = _player.global_position.x - global_position.x
	_dir = 1 if dx >= 0.0 else -1
	var desired := Vector2(signf(dx) * cruise_speed, clampf((mark.y - global_position.y) * 2.0, -cruise_speed, cruise_speed))
	if absf(dx) < hold_distance:
		desired.x *= 0.1
	velocity = velocity.move_toward(desired, accel * delta)
	if _attack_timer <= 0.0:
		_begin_swoop()


func _begin_swoop() -> void:
	var aim: Vector2 = _player.global_position + _player.velocity * swoop_lead
	_dive_dir = (aim - global_position).normalized()
	if _dive_dir == Vector2.ZERO:
		_dive_dir = Vector2.DOWN
	_state = State.SWOOP
	_timer = swoop_duration
	sprite.texture = dive_texture


func _swoop(delta: float) -> void:
	if _player != null:
		var to_player: Vector2 = _player.global_position - global_position
		if to_player.length() > 1.0:
			_dive_dir = _dive_dir.lerp(to_player.normalized(), clampf(delta * 2.2, 0.0, 1.0))
	velocity = velocity.move_toward(_dive_dir * swoop_speed, accel * 4.0 * delta)
	_dir = 1 if velocity.x >= 0.0 else -1
	if _timer <= 0.0 or global_position.distance_to(_player.global_position) < 40.0:
		_state = State.RETURN
		_timer = return_duration
		_frame = 0
		_frame_timer = 0.0


func _retreat(delta: float) -> void:
	_animate_flap(delta)
	var mark: Vector2 = _player.global_position + Vector2(0, -hover_height * 1.4)
	var away: Vector2 = global_position - _player.global_position
	if away.length() < 1.0:
		away = Vector2.UP
	var desired: Vector2 = away.normalized() * return_speed + Vector2(0, (mark.y - global_position.y))
	velocity = velocity.move_toward(desired.limit_length(return_speed), accel * delta)
	_dir = 1 if velocity.x >= 0.0 else -1
	if _timer <= 0.0:
		_state = State.CRUISE
		_attack_timer = attack_interval


func _animate_flap(delta: float) -> void:
	if sprite.texture == dive_texture:
		sprite.texture = flap_a
		_frame = 0
		_frame_timer = 0.0
	_frame_timer += delta
	if _frame_timer >= flap_time:
		_frame_timer -= flap_time
		_frame = (_frame + 1) % 3
		match _frame:
			0:
				sprite.texture = flap_a
			1:
				sprite.texture = flap_b
			_:
				sprite.texture = flap_c


func _player_can_see() -> bool:
	var cam: Camera2D = _player.get_node_or_null("Camera") as Camera2D
	if cam == null:
		return global_position.distance_to(_player.global_position) < 1300.0
	var center: Vector2 = cam.get_screen_center_position()
	var half: Vector2 = get_viewport_rect().size * 0.5 / cam.zoom
	return absf(global_position.x - center.x) <= half.x + 180.0 and absf(global_position.y - center.y) <= half.y + 180.0
