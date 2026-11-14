extends Control

const BACKGROUND_ART := "res://assets/ui/menu_background.png"
const TITLE_ART := "res://assets/ui/title.png"
const LEVEL_SELECT := "res://scenes/ui/level_select.tscn"

@onready var background: TextureRect = $Background
@onready var title_art: TextureRect = $TitleArt
@onready var title_text: Label = $TitleText
@onready var credits_overlay: Control = $CreditsOverlay


func _ready() -> void:
	if ResourceLoader.exists(BACKGROUND_ART):
		background.texture = load(BACKGROUND_ART)
	if ResourceLoader.exists(TITLE_ART):
		title_art.texture = load(TITLE_ART)
		title_text.hide()

	credits_overlay.hide()
	$ButtonsPanel/PlayButton.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_SELECT)


func _on_credits_pressed() -> void:
	credits_overlay.modulate.a = 0.0
	credits_overlay.show()
	create_tween().tween_property(credits_overlay, "modulate:a", 1.0, 0.18)
	$CreditsOverlay/Panel/CloseButton.grab_focus()


func _on_close_pressed() -> void:
	credits_overlay.hide()
	$ButtonsPanel/CreditsButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if credits_overlay.visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
