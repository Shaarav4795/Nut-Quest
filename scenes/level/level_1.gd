extends Node2D

@export var kill_y := 180.0

@onready var player: CharacterBody2D = find_child("Player", true, false) as CharacterBody2D


func _ready() -> void:
	Audio.play_level_music()
	if player == null:
		return
	player.bounced.connect(Audio.play_jump)
	player.died.connect(Audio.play_die)


func _physics_process(_delta: float) -> void:
	if player.position.y > kill_y:
		player.die()
