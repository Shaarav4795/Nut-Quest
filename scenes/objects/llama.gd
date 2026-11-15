extends CharacterBody2D

@export_group("Movement")
@export var walk_speed := 55.0
@export var ground_accel := 600.0
@export var gravity := 1400.0

@export_group("Chase")
@export var patrol_left := -220.0
@export var patrol_right := 220.0
@export var follow_stop := 190.0

@export_group("Attack")
@export var spit_scene: PackedScene = preload("res://scenes/objects/llama_spit.tscn")
@export var fire_interval := 2.2
@export var first_shot_delay := 1.5
@export var windup := 0.7
@export var spit_speed := 190.0
@export var muzzle := Vector2(70, -150)
@export var min_range := 170.0
@export var charge_grow := 0.14

@export_group("Art")
@export var idle_texture: Texture2D = preload("res://assets/squirrel/LamaIdle.png")
@export var walk_frame_a: Texture2D = preload("res://assets/squirrel/LamaWalk1.png")
@export var walk_frame_b: Texture2D = preload("res://assets/squirrel/LamaWalk2.png")
@export var walk_frame_time := 0.18

@onready var sprite: Sprite2D = $Sprite
@onready var ledge_check: RayCast2D = $LedgeCheck

var _dir := 1
var _home_x := 0.0
var _frame := 0
var _frame_timer := 0.0
var _shot_timer := 0.0
var _charge_timer := 0.0
var _charging := false
var _base_scale := Vector2.ONE
var _player: Node2D = null
var _awake := false


func _ready() -> void:
	_home_x = global_position.x
	_shot_timer = first_shot_delay
	_base_scale = sprite.scale
	sprite.texture = idle_texture
	var scene: Node = get_tree().current_scene
	if scene != null:
		_player = scene.find_child("Player", true, false) as Node2D
	$HurtBox.body_entered.connect(_on_touch)


func is_awake() -> bool:
	return _awake


func _on_touch(body: Node) -> void:
	if body == _player:
		body.call("die")


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	_awake = _player != null and _player_can_see()

	if not _awake:
		_cancel_charge()
		_shot_timer = first_shot_delay
		velocity.x = move_toward(velocity.x, 0.0, ground_accel * delta)
		sprite.texture = idle_texture
	elif _charging:
		_face_player()
		velocity.x = move_toward(velocity.x, 0.0, ground_accel * delta)
		_charge_timer -= delta
		var swell: float = 1.0 - clampf(_charge_timer / maxf(windup, 0.01), 0.0, 1.0)
		sprite.scale = _base_scale * (1.0 + charge_grow * swell)
		sprite.texture = idle_texture
		if _charge_timer <= 0.0:
			_cancel_charge()
			_shot_timer = fire_interval
			_spit()
	else:
		_follow(delta)
		if absf(velocity.x) > 5.0:
			_animate_walk(delta)
		else:
			sprite.texture = idle_texture
		_shot_timer -= delta
		if _shot_timer <= 0.0 and _player_in_range():
			_charging = true
			_charge_timer = windup

	move_and_slide()
	sprite.flip_h = _dir < 0


func _cancel_charge() -> void:
	_charging = false
	sprite.scale = _base_scale


func _player_in_range() -> bool:
	return global_position.distance_to(_player.global_position) >= min_range


func _face_player() -> void:
	var dx: float = _player.global_position.x - global_position.x
	if absf(dx) > 4.0:
		var new_dir: int = 1 if dx > 0.0 else -1
		if new_dir != _dir:
			_dir = new_dir
			velocity.x = 0.0


func _follow(delta: float) -> void:
	var gap: float = _player.global_position.x - global_position.x
	var before := _dir
	if absf(gap) > 6.0:
		_dir = 1 if gap > 0.0 else -1
	var target_speed := 0.0
	if absf(gap) > follow_stop and _within_leash() and _ground_ahead():
		target_speed = _dir * walk_speed
	if is_on_wall():
		target_speed = 0.0
	velocity.x = move_toward(velocity.x, target_speed, ground_accel * delta)
	if _dir != before:
		velocity.x = 0.0


func _within_leash() -> bool:
	var offset_x := global_position.x - _home_x
	if _dir > 0:
		return offset_x < patrol_right
	return offset_x > patrol_left


func _animate_walk(delta: float) -> void:
	_frame_timer += delta
	if _frame_timer >= walk_frame_time:
		_frame_timer -= walk_frame_time
		_frame = 1 - _frame
		sprite.texture = walk_frame_a if _frame == 0 else walk_frame_b


func _spit() -> void:
	var origin: Vector2 = global_position + Vector2(muzzle.x * _dir, muzzle.y)
	var aim: Vector2 = (_player.global_position - origin).normalized()
	if aim == Vector2.ZERO:
		return
	var spit: Node2D = spit_scene.instantiate()
	get_parent().add_child(spit)
	spit.global_position = origin
	spit.call("setup", aim, spit_speed)


func _player_can_see() -> bool:
	var cam: Camera2D = _player.get_node_or_null("Camera") as Camera2D
	if cam == null:
		return global_position.distance_to(_player.global_position) < 1200.0
	var center: Vector2 = cam.get_screen_center_position()
	var half: Vector2 = get_viewport_rect().size * 0.5 / cam.zoom
	return absf(global_position.x - center.x) <= half.x + 80.0 and absf(global_position.y - center.y) <= half.y + 80.0


func _ground_ahead() -> bool:
	ledge_check.position.x = _dir * 60.0
	ledge_check.force_raycast_update()
	return ledge_check.is_colliding()
