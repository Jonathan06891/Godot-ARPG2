extends Node2D

var current_level = 0
var levels = ["res://Scenes/Title.tscn", "res://Scenes/Level1.tscn", "res://Scenes/Dead.tscn"]

func restart():
	current_level = 0
	get_tree().change_scene(levels[current_level])

func next_level():
	current_level += 1
	if current_level < levels.size():
		get_tree().change_scene(levels[current_level])
	else:
		restart()
		
func died():
	current_level = 2
	get_tree().change_scene(levels[current_level])
