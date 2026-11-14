extends CanvasLayer

const LEVEL_SELECT := "res://scenes/ui/level_select.tscn"

@onready var overlay: Control = $Root/Overlay
@onready var back_button: Button = $Root/BackButton
@onready var resume_button: Button = $Root/Overlay/Panel/ResumeButton
@onready var exit_button: Button = $Root/Overlay/Panel/ExitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.hide()
	back_button.pressed.connect(_open)
	resume_button.pressed.connect(_close)
	exit_button.pressed.connect(_exit_level)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return

	if overlay.visible:
		_close()
	else:
		_open()
	get_viewport().set_input_as_handled()


func _open() -> void:
	if get_tree().paused:
		return
	overlay.show()
	get_tree().paused = true
	resume_button.grab_focus()


func _close() -> void:
	overlay.hide()
	get_tree().paused = false


func _exit_level() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_SELECT)
