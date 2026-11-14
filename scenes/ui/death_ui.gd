extends CanvasLayer

const LEVEL_SELECT := "res://scenes/ui/level_select.tscn"

@onready var overlay: Control = $Root/Overlay
@onready var respawn_button: Button = $Root/Overlay/Panel/RespawnButton
@onready var exit_button: Button = $Root/Overlay/Panel/ExitButton

var player: CharacterBody2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.hide()

	player = get_parent().find_child("Player", true, false) as CharacterBody2D
	if player != null:
		player.died.connect(_on_player_died)

	respawn_button.pressed.connect(_respawn)
	exit_button.pressed.connect(_exit_level)


func _on_player_died() -> void:
	overlay.show()
	get_tree().paused = true
	respawn_button.grab_focus()


func _respawn() -> void:
	overlay.hide()
	get_tree().paused = false
	if player != null:
		player.revive()


func _exit_level() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_SELECT)
