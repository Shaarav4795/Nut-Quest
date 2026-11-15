extends Area2D

@export var speed := 190.0
@export var lifetime := 5.0

var _dir := Vector2.RIGHT
var _age := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func setup(direction: Vector2, new_speed: float) -> void:
	_dir = direction.normalized()
	speed = new_speed


func _physics_process(delta: float) -> void:
	global_position += _dir * speed * delta
	_age += delta
	if _age >= lifetime:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("die"):
		body.die()
	queue_free()
