extends Control

onready var scene_tree: = get_tree()
onready var pause_overlay: ColorRect = get_node("PauseOverlay")

var paused: = false setget set_paused

func _ready():
	pass

func _on_Continue_button_up():
	self.paused = not paused
	scene_tree.set_input_as_handled()
	
func _on_Load_button_up():
	self.paused = not paused
	scene_tree.set_input_as_handled()
	SAVER.playerload = true
	$"/root/SAVER".loadValue("Values", "Currentscene")
	Screenloader.change_scene("res://Scenes/"+$"/root/SAVER".savedata+".tscn")

func _on_Main_Menu_button_up():
	self.paused = not paused
	scene_tree.set_input_as_handled()
	get_tree().change_scene("res://Scenes/Title.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and get_node("../../Player").get("use") == false:
		self.paused = not paused
		scene_tree.set_input_as_handled()

func set_paused(value: bool) -> void:
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value


