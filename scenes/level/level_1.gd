extends Node2D

@export var kill_y := 300.0

@onready var player: CharacterBody2D = find_child("Player", true, false) as CharacterBody2D


func _physics_process(_delta: float) -> void:
	if player.position.y > kill_y:
		player.respawn()
