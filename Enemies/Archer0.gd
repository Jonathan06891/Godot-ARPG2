extends KinematicBody2D

signal stamina_changed
signal attack
signal health_changed
signal shoot

export (PackedScene) var Arrow
export (int) var detect_radius

var movetimer_length = 15
var movetimer = 0
var hitstun = 0
var canshoot = true
var canshoot2 = true
var target = null
var hand_speed = 100
var SPEED = 100
var dframes = 5
var maxstamina = 100
var alive = true
var maxhealth = 100

var knockdir = Vector2(0,0)
var movedir = Vector2(0,0)
var spritedir = "down"
var stamina
var health

func _ready():
	set_physics_process(false)
	set_process(false)
	movedir = dir.rand()
	var circle = CircleShape2D.new()
	$Detectradius/CollisionShape2D.shape = circle
	$Detectradius/CollisionShape2D.shape.radius = detect_radius
	stamina = maxstamina
	health = maxhealth
	emit_signal("stamina_changed", stamina * 100/maxstamina)
	emit_signal("health_changed", health * 100/maxhealth)

func _physics_process(delta):
	if movetimer > 0:
		movetimer -= 1
	if movetimer == 0 or is_on_wall():
		movedir = dir.rand()
		movetimer = movetimer_length
	movement_loop()
	stamina_regen()
	knockback_loop()
	$Shoot.wait_time = rand_range(0.5, 1.5)
	
func _process(delta):
	if target:
		var target_dir = (target.global_position - global_position).normalized()
		var current_dir = Vector2(1, 0).rotated($hand.global_rotation)
		$hand.global_rotation = target_dir.angle()
		if target_dir.dot(current_dir) > .98 and canshoot == true and canshoot2 == true and stamina == 100:
			shoot()
			var musicNodebow = $"Node2D/Bowshot"
			musicNodebow.play()
			stamina -= 50
			canshoot = false

	if movedir != Vector2(0,0):
		anim_switch("walk")
	else:
		anim_switch("idle")

func stamina_regen():
	if stamina < maxstamina:
		stamina = clamp(stamina, 0, maxstamina)
		stamina += 2
		emit_signal("stamina_changed", stamina * 100/maxstamina)
	if stamina > maxstamina:
		stamina = maxstamina
		emit_signal("stamina_changed", stamina * 100/maxstamina)

func movement_loop():
	var motion
	if hitstun == 0:
		motion = movedir.normalized() * SPEED
	else:
		motion = knockdir.normalized() * SPEED * 2.5
	move_and_slide(motion, Vector2(0,0))

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
	var musicNodehit = $"Node2D/Hit"
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
		SPEED = 100
		set_modulate(Color(1,1,1,1))
			
func shoot():
	$Shoot.start()
	var dir = Vector2(1, 0).rotated($hand.global_rotation)
	emit_signal("shoot", Arrow, $hand/Aim.global_position, dir)

func _on_Detectradius_body_entered(body):
	if body.name == "Player":
		target = body

func _on_Detectradius_body_exited(body):
	if body == target:
		target = null

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
