extends Node


func _on_Enemy_shoot(arrow, _position, _direction):
	var a = arrow.instance()
	add_child(a)
	a.start(_position, _direction)
	
