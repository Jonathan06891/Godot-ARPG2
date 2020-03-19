extends Control

onready var scene_tree: = get_tree()
onready var pause_overlay: ColorRect = get_node("PauseOverlay")

var paused: = false setget set_paused

func _ready():
	pass

func _on_Yes_button_up():
	self.paused = not paused
	scene_tree.set_input_as_handled()
	SAVER.savedata = get_node("../../Player").transform.origin
	$"/root/SAVER".saveValue("Values", "Playerpos")
	SAVER.savedata = get_tree().get_current_scene().get_name()
	$"/root/SAVER".saveValue("Values", "Currentscene")
	SAVER.playerload = true
	$"/root/SAVER".loadValue("Values", "Currentscene")
	Screenloader.change_scene("res://Scenes/"+$"/root/SAVER".savedata+".tscn")
	
func _on_No_button_up():
	self.paused = not paused
	scene_tree.set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and get_node("../../Saveshrine0").get("use") == true:
		self.paused = not paused
		scene_tree.set_input_as_handled()

func set_paused(value: bool) -> void:
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value


