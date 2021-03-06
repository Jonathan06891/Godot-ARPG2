extends Node2D

var TYPE = "weapon"
var speed = .01
var damage = 60
var lifetime = 1
var velocity = Vector2()

func start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	yield(get_tree().create_timer(0.22), "timeout")
	queue_free()

func _on_sword_body_entered(body):
	if body.has_method("take_damage") and body.get("TYPE") == "player":
		body.take_damage(damage)
