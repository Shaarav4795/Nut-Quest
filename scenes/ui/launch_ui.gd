extends CanvasLayer

@export var held_zoom := 0.6
@export var zoom_time := 0.45

@onready var button: Button = $Root/LaunchButton
@onready var subtitle: Label = $Root/Subtitle

var player: CharacterBody2D
var slingshot: Node2D
var target: Node2D
var camera: Camera2D
var play_zoom := Vector2.ONE

var _holding := false
var _pending_subtitle := false
var _zoom_tween: Tween


func _ready() -> void:
	var level := get_parent()
	player = level.find_child("Player", true, false) as CharacterBody2D
	slingshot = level.get_node_or_null("Slingshot") as Node2D
	target = level.find_child("LaunchTarget", true, false) as Node2D

	if player != null:
		camera = player.get_node_or_null("Camera") as Camera2D
		player.landed.connect(_on_player_landed)
	if camera != null:
		play_zoom = camera.zoom

	button.pressed.connect(_on_launch_pressed)

	if player != null and slingshot != null:
		player.hold(slingshot.muzzle_position())

	_refresh()


func _process(_delta: float) -> void:
	_refresh()


func _refresh() -> void:
	var held: bool = player != null and player.is_held()
	button.visible = held

	if camera == null:
		return

	if held and not _holding:
		_holding = true
		if _zoom_tween != null and _zoom_tween.is_valid():
			_zoom_tween.kill()
		camera.zoom = Vector2(held_zoom, held_zoom)
	elif not held and _holding:
		_holding = false
		_zoom_tween = create_tween()
		_zoom_tween.tween_property(camera, "zoom", play_zoom, zoom_time) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_launch_pressed() -> void:
	if player == null or slingshot == null or target == null:
		return

	_pending_subtitle = player.revived_count > 0
	player.launch_to(target.global_position, slingshot.flight_time)
	slingshot.recoil(target.global_position - slingshot.muzzle_position())
	_refresh()


func _on_player_landed() -> void:
	if not _pending_subtitle:
		return

	_pending_subtitle = false
	subtitle.visible = true
	subtitle.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(subtitle, "modulate:a", 1.0, 0.25)
	tween.tween_interval(1.5)
	tween.tween_property(subtitle, "modulate:a", 0.0, 0.5)
	tween.tween_callback(subtitle.hide)
