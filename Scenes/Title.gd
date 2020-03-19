extends Control

func _on_NewGame_button_up():
	Screenloader.change_scene("res://Scenes/Scene0a.tscn")

func _on_LoadGame_button_up():
	SAVER.playerload = true
	$"/root/SAVER".loadValue("Values", "Currentscene")
	Screenloader.change_scene("res://Scenes/"+$"/root/SAVER".savedata+".tscn")

func _on_Controls_button_up():
	get_tree().change_scene("res://Scenes/Controls.tscn")

func _on_Credits_button_up():
	get_tree().change_scene("res://Scenes/Credits.tscn")

func _on_Quit_button_up():
	get_tree().quit()
