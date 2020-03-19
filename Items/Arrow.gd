extends Node2D

signal health_changed

var TYPE = "aweapon"
var speed = 500
var damage = 40
var lifetime = 1
var velocity = Vector2()
var maxhealth = 10
var health

func _ready():
	health = maxhealth
	emit_signal("health_changed", health * 100/maxhealth)
	
func take_damage(amount):
	health -= amount
	emit_signal("health_changed", health * 100/maxhealth)
	if health <= 0:
		queue_free()

func start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed
	
func _process(delta):
	position += velocity * delta
#	yield(get_tree().create_timer(10), "timeout")
#	queue_free()

func _on_arrow_body_entered(body):
	if body.has_method("take_damage") and body.get("TYPE") == "player":
		body.take_damage(damage)
	queue_free()
