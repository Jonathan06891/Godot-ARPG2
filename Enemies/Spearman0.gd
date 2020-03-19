extends KinematicBody2D

signal stamina_changed
signal attack
signal health_changed
signal shoot

export (PackedScene) var Spear

var movetimer_length = 15
var movetimer = 0
var hitstun = 0
var canshoot = true
var canshoot2 = true
var target = null
var target2 = null
var hand_speed = 6
var SPEED = 250
var dframes = 5
var maxstamina = 100
var alive = true
var maxhealth = 100
var _velocity = Vector2(0,0)

var knockdir = Vector2(0,0)
var spritedir = "down"
var stamina
var health

func _ready():
	set_physics_process(false)
	set_process(false)
	stamina = maxstamina
	health = maxhealth
	emit_signal("stamina_changed", stamina * 100/maxstamina)
	emit_signal("health_changed", health * 100/maxhealth)

func _physics_process(delta):
	if target2:
		_velocity = Steering.follow(
			_velocity,
			global_position,
			target2.global_position,
			SPEED
		)
	if stamina <= 30:
		_velocity = Vector2(0,0)
	if target2 == null:
		_velocity = Vector2(0,0)	
	movement_loop()
	stamina_regen()
	knockback_loop()
	$Shoot.wait_time = rand_range(0.5, 1.5)
	
func _process(delta):
	if target2:
		var target2_dir = (target2.global_position - global_position).normalized()
		var current_dir = Vector2(1, 0).rotated($hand.global_rotation)
		$hand.global_rotation = current_dir.linear_interpolate(target2_dir, hand_speed * delta).angle()
	if target:
		var target_dir = (target.global_position - global_position).normalized()
		var current_dir = Vector2(1, 0).rotated($hand.global_rotation)
		$hand.global_rotation = current_dir.linear_interpolate(target_dir, hand_speed * delta).angle()
		if target_dir.dot(current_dir) > .98 and canshoot == true and canshoot2 == true and stamina >= 50:
			shoot()
			var musicNodebow = $"Sounds/Attack"
			musicNodebow.play()
			stamina -= 50
			canshoot = false

	if _velocity != Vector2(0,0):
		anim_switch("walk")
	else:
		anim_switch("idle")

func stamina_regen():
	if stamina < 100:
		stamina = clamp(stamina, 0, 100)
		stamina += .08
		emit_signal("stamina_changed", stamina * 100/maxstamina)
	if stamina < 100 and _velocity == Vector2(0,0):
		stamina = clamp(stamina, 0, 100)
		stamina += .4
		emit_signal("stamina_changed", stamina * 100/maxstamina)

func movement_loop():
	var motion
	if hitstun == 0:
		motion = _velocity.normalized() * SPEED
	else:
		motion = -_velocity.normalized() * SPEED * 2.5
	move_and_slide(motion, _velocity)

func knockback_loop():
	if hitstun > 0:
		hitstun -= 1
	for area in $knockbox.get_overlapping_areas():
		var body = area.get_parent()
		if hitstun == 0 and body.get("TYPE") == "pweapon":
			hitstun = 10
			knockdir = global_transform.origin - body.global_transform.origin

func anim_switch(animation):
	var newanim = str(animation,spritedir)
	if $Anima.current_animation != newanim:
		$Anima.play(newanim)

func take_damage(amount):
	health -= amount
	stamina -= amount
	emit_signal("health_changed", health * 100/maxhealth)
	emit_signal("stamina_changed", stamina * 100/maxhealth)
	var musicNodehit = $"Sounds/Hit"
	musicNodehit.play()
	if health <= 0:
		canshoot2 = false
		SPEED = 0
		set_modulate(Color(1,1,1,0.5))
		yield(get_tree().create_timer(0.5), "timeout")
		queue_free()
	else:
		SPEED = 50
		set_modulate(Color(1,1,1,0.5))
		yield(get_tree().create_timer(0.5), "timeout")
		SPEED = 250
		set_modulate(Color(1,1,1,1))
			
func shoot():
	$Shoot.start()
	var dir = Vector2(0, 1).rotated($hand/Aim.global_rotation)
	emit_signal("attack", Spear, transform.xform_inv($hand/Aim.global_position), dir)
	
func _on_Spearman0_attack(Spear, _position, _direction):
	var s = Spear.instance()
	add_child(s)
	s.start(_position, _direction)

func _on_Detectradius_body_entered(body):
	if body.name == "Player":
		target = body

func _on_Detectradius_body_exited(body):
	if body == target:
		target = null
		
func _on_Sightradius_body_entered(body):
	if body.name == "Player":
		target2 = body
		
func _on_Sightradius_body_exited(body):
	if body == target2:
		target2 = null

func _on_NorthQ_body_entered(body):
	if body.get("TYPE") == "player":
		spritedir = "up"

func _on_WestQ_body_entered(body):
	if body.get("TYPE") == "player":
		spritedir = "left"

func _on_SouthQ_body_entered(body):
	if body.get("TYPE") == "player":
		spritedir = "down"

func _on_EastQ_body_entered(body):
	if body.get("TYPE") == "player":
		spritedir = "right"

func _on_Shoot_timeout():
	canshoot = true

func _on_VisibilityEnabler2D_screen_entered():
	set_physics_process(true)
	set_process(true)

func _on_VisibilityEnabler2D_screen_exited():
	set_physics_process(false)
	set_process(false)

