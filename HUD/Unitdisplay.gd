extends Node2D

var healthbar = preload("res://HUD/Health Bar.png")
var staminabar = preload("res://HUD/Stamina Bar.png")

func _ready():
	for node in get_children():
		node.hide()

func _process(delta):
	global_rotation = 0

func update_healthbar(value):
	if value < 100:
		$HealthBar.show()
	$HealthBar.texture_progress = healthbar
	$HealthBar.value = value
	
func update_staminabar(value):
	if value < 100:
		$StaminaBar.show()
	$StaminaBar.texture_progress = staminabar
	$StaminaBar.value = value
