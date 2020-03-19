extends KinematicBody2D

signal stamina_changed
signal attack
signal health_changed
signal dead

export (PackedScene) var Sword
export (PackedScene) var SwordW

onready var SAVE_KEY : String = "party_member_" + name

var TYPE = "player"
var SPEED = 300
var dframes = 5
var maxstamina = 100
var alive = true
var maxhealth = 100
var movedir = Vector2(0,0)
var knockdir = Vector2(0,0)
var spritedir = "down"
var stamina
var health
var hitstun = 0
var blocking = false
var occupied = false
var west = false

func _ready():
	stamina = maxstamina
	health = maxhealth
	emit_signal("stamina_changed", stamina * 100/maxstamina)
	emit_signal("health_changed", health * 100/maxhealth)
	if SAVER.playerload == true:
		$"/root/SAVER".loadValue("Values", "Playerpos")
		position = $"/root/SAVER".savedata
		SAVER.playerload = false

func _physics_process(delta):
	$hand.look_at(get_global_mouse_position())
	controls_loop()
	movement_loop()
	dash_loop()
	stamina_regen()
	attack_loop()
	knockback_loop()
	block_loop()
	occupied_loop()

	if movedir != Vector2(0,0):
		anim_switch("walk")
	else:
		anim_switch("idle")

func controls_loop():
	var LEFT  = Input.is_action_pressed("ui_left")
	var RIGHT = Input.is_action_pressed("ui_right")
	var UP    = Input.is_action_pressed("ui_up")
	var DOWN  = Input.is_action_pressed("ui_down")

	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)

func attack():
	var dir = Vector2(0, 1).rotated($hand/Aim.global_rotation)
	emit_signal("attack", Sword, transform.xform_inv($hand/Aim.global_position), dir)
func attackw():
	var dir = Vector2(0, 1).rotated($hand/Aim.global_rotation)
	emit_signal("attack", SwordW, transform.xform_inv($hand/Aim.global_position), dir)
	
func _on_player_attack(Sword, _position, _direction):
	var s = Sword.instance()
	add_child(s)
	s.start(_position, _direction)
	
func attack_loop():
	if stamina < 10:
		return
	if Input.is_action_just_pressed("l_click") and west == false:
		var musicNode = $"Node2D/Swordswing"
		musicNode.play()
		attack()
		stamina -= 25
	if Input.is_action_just_pressed("l_click") and west == true:
		var musicNode = $"Node2D/Swordswing"
		musicNode.play()
		attackw()
		stamina -= 25
		
func block_loop():
	if Input.is_action_pressed("r_click") and stamina >= 35:
		$Shield.set_modulate(Color(1,1,1,1))
		blocking = true
		SPEED = 100
	if Input.is_action_just_released("r_click") or stamina <= 1:
		$Shield.set_modulate(Color(1,1,1,0))
		blocking = false
		SPEED = 300
		
func occupied_loop():
	if get_node("../Saveshrine0").get("use") == true:
		occupied = true

func dash_loop():
	if stamina < 10:
		return
	if Input.is_action_just_pressed("ui_dash") && (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
		SPEED = 1300
		stamina -= 15
		set_collision_mask_bit(2,false)
		set_collision_layer_bit(2,false)
		set_modulate(Color(1,1,1,0.15))
		emit_signal("stamina_changed", stamina * 100/maxstamina)
		var musicNodedash = $"Node2D/Dash"
		musicNodedash.play()
		yield(get_tree().create_timer(0.09), "timeout")
		set_collision_mask_bit(2,true)
		set_collision_layer_bit(2,true)
		set_modulate(Color(1,1,1,1))
		SPEED = 300
		stamina = clamp(stamina, 0, 100)
		
func stamina_regen():
	if stamina < 100:
		stamina = clamp(stamina, 0, 100)
		stamina += .08
		emit_signal("stamina_changed", stamina * 100/maxstamina)
	if stamina < 100 and movedir == Vector2(0,0):
		stamina = clamp(stamina, 0, 100)
		stamina += .4
		emit_signal("stamina_changed", stamina * 100/maxstamina)
	if stamina > 100:
		stamina = 100
		emit_signal("stamina_changed", stamina * 100/maxstamina)
	if blocking == true:
		stamina -= .6
		emit_signal("stamina_changed", stamina * 100/maxstamina)

func movement_loop():
	var motion
	if hitstun == 0:
		motion = movedir.normalized() * SPEED
	else:
		motion = knockdir.normalized() * SPEED * 1.5
	move_and_slide(motion, Vector2(0,0))

func anim_switch(animation):
	var newanim = str(animation,spritedir)
	if $Anima.current_animation != newanim:
		$Anima.play(newanim)

func knockback_loop():
	if hitstun > 0:
		hitstun -= 1
	for body in $knockbox.get_overlapping_bodies():
		if hitstun == 0 and body.get("TYPE") == "weapon":
			hitstun = 10
			knockdir = transform.origin - body.transform.origin
			
func take_damage(amount):
	if blocking == false:
		health -= amount
		stamina -= amount
		var musicNodehit = $"Node2D/Hit"
		musicNodehit.play()
		if health <= 0:
			emit_signal("dead")
			queue_free()
		else:
			SPEED = 150
			set_modulate(Color(1,1,1,0.5))
			emit_signal("health_changed", health * 100/maxhealth)
			emit_signal("stamina_changed", stamina * 100/maxhealth)
			yield(get_tree().create_timer(0.5), "timeout")
			SPEED = 300
			set_modulate(Color(1,1,1,1))
	if blocking == true:
		stamina -= amount / 3
		var musicNodehit = $"Node2D/Block"
		musicNodehit.play()

func _on_Area2D_mouse_entered():
	spritedir = "up"
	west = false

func _on_Area2D2_mouse_entered():
	spritedir = "right"
	west = false

func _on_Area2D3_mouse_entered():
	spritedir = "down"
	west = true

func _on_Area2D4_mouse_entered():
	spritedir = "left"
	west = true

func _on_Player_dead():
	GLOBALS.died()
	
func save(save_game : Resource):
	save_game.data[SAVE_KEY] = $Player.transform.origin
	
func load(save_game : Resource):
	$Player.transform.origin = save_game.data[SAVE_KEY]
