extends Control

func _on_Retry_button_up():
	SAVER.playerload = true
	$"/root/SAVER".loadValue("Values", "Currentscene")
	Screenloader.change_scene("res://Scenes/"+$"/root/SAVER".savedata+".tscn")

func _on_MainMenu_button_up():
	Screenloader.change_scene("res://Scenes/Title.tscn")

func _on_Quit_button_up():
	get_tree().quit()
