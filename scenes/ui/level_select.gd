extends Control

const PREVIEW_DIR := "res://assets/ui/level_thumbs/"
const MAIN_MENU := "res://scenes/ui/main_menu.tscn"

@onready var preview: TextureRect = $Card/PreviewFrame/Preview
@onready var lock_overlay: Control = $Card/PreviewFrame/LockOverlay
@onready var level_label: Label = $Card/LevelLabel
@onready var play_button: Button = $Card/PlayButton
@onready var left_button: Button = $LeftButton
@onready var right_button: Button = $RightButton

var _index := 0


func _ready() -> void:
	_refresh()
	play_button.grab_focus()


func _refresh() -> void:
	var unlocked: bool = Progress.is_unlocked(_index)

	level_label.text = "LEVEL %d" % (_index + 1)
	lock_overlay.visible = not unlocked
	play_button.disabled = not unlocked
	play_button.text = "PLAY" if unlocked else "LOCKED"
	left_button.disabled = _index == 0
	right_button.disabled = _index == Progress.level_count() - 1

	var path: String = PREVIEW_DIR + "level_%d.png" % (_index + 1)
	preview.texture = load(path) if ResourceLoader.exists(path) else null


func _select(index: int) -> void:
	_index = clampi(index, 0, Progress.level_count() - 1)
	_refresh()


func _on_left_pressed() -> void:
	_select(_index - 1)


func _on_right_pressed() -> void:
	_select(_index + 1)


func _on_play_pressed() -> void:
	if Progress.is_unlocked(_index):
		get_tree().change_scene_to_file(Progress.scene_path(_index))


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()
