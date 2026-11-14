extends Node2D

@export var flight_time := 0.7
@export var recoil_distance := 9.0
@export var recoil_angle := 7.0
@export var recoil_time := 0.38

@onready var art: Sprite2D = $Art
@onready var muzzle: Marker2D = $Muzzle

var _rest_position := Vector2.ZERO
var _rest_rotation := 0.0
var _recoil: Tween


func _ready() -> void:
	_rest_position = art.position
	_rest_rotation = art.rotation


func muzzle_position() -> Vector2:
	return muzzle.global_position


func recoil(launch_dir: Vector2) -> void:
	if _recoil != null and _recoil.is_valid():
		_recoil.kill()

	var side := signf(launch_dir.x)
	art.position = _rest_position - launch_dir.normalized() * recoil_distance
	art.rotation = _rest_rotation - side * deg_to_rad(recoil_angle)

	_recoil = create_tween()
	_recoil.set_parallel(true)
	_recoil.tween_property(art, "position", _rest_position, recoil_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_recoil.tween_property(art, "rotation", _rest_rotation, recoil_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
