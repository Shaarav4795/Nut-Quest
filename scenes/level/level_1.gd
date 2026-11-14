extends Node2D

# Player is a direct child, so this is in the level's local coordinates.
# The ground row bottom sits at y = 149, so 300 is well below it: the player
# only passes this by falling off the level.
@export var kill_y := 300.0

@onready var player: CharacterBody2D = $Player


func _physics_process(_delta: float) -> void:
	if player.position.y > kill_y:
		player.respawn()
