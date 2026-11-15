extends CanvasLayer

const LEVEL_SELECT := "res://scenes/ui/level_select.tscn"

@export var survive_time := 15.0
@export var level_index := 0

@onready var bar_frame: Control = $Root/BarFrame
@onready var bar: ProgressBar = $Root/BarFrame/Bar
@onready var time_label: Label = $Root/BarFrame/TimeLabel
@onready var overlay: Control = $Root/CompleteOverlay
@onready var panel: Panel = $Root/CompleteOverlay/Panel
@onready var continue_button: Button = $Root/CompleteOverlay/Panel/ContinueButton

var _llama: Node = null
var _player: Node = null
var _remaining := 0.0
var _shown := false
var _done := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.hide()
	bar_frame.hide()
	_remaining = survive_time
	bar.max_value = survive_time
	bar.value = survive_time
	time_label.text = "%d" % int(survive_time)

	var level: Node = get_parent()
	_llama = level.find_child("Llama", true, false)
	_player = level.find_child("Player", true, false)
	if _player != null:
		_player.died.connect(_on_player_died)

	continue_button.pressed.connect(_continue)


func _process(delta: float) -> void:
	if _done or _llama == null or get_tree().paused:
		return
	if not bool(_llama.call("is_awake")):
		return
	if not _shown:
		_shown = true
		bar_frame.show()

	_remaining = maxf(_remaining - delta, 0.0)
	bar.value = _remaining
	time_label.text = "%d" % int(ceilf(_remaining))
	if _remaining <= 0.0:
		_complete()


func _on_player_died() -> void:
	if _done:
		return
	_remaining = survive_time
	bar.value = _remaining
	time_label.text = "%d" % int(survive_time)


func _complete() -> void:
	_done = true
	bar_frame.hide()
	overlay.show()
	Progress.complete(level_index)
	get_tree().paused = true
	continue_button.grab_focus()

	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.88, 0.88)
	overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.18)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _continue() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_SELECT)
