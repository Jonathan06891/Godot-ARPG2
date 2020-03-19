extends Node

var savedata
var playerload = false

var save_path = "user://save_file.cfg"
var config = ConfigFile.new()
var load_response = config.load(save_path)

func _ready():
	pass
	
func saveValue(section, key):
	config.set_value(section, key, savedata)
	config.save(save_path)

func loadValue(section, key):
	savedata = config.get_value(section, key, savedata)
