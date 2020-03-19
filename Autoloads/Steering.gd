extends Node

const DEFAULT_MASS = 2.0

static func follow(
		velocity: Vector2,
		global_position: Vector2,
		target_position: Vector2,
		max_speed: float,
		mass: = DEFAULT_MASS
	) -> Vector2:
	var desired_velocity: = (target_position - global_position).normalized() * max_speed
	var steering: = (desired_velocity - velocity) / mass
	var new_velocity: = Vector2.ZERO
	return velocity + steering
