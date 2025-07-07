extends Node

signal saved_data
signal loaded_data(save_file_exists: bool)

const SAVENAME: String = "savegame.sav"
var save_file_exists: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_data()

func save_data() -> void:
	var save_file: FileAccess = FileAccess.open(OS.get_user_data_dir().path_join(SAVENAME), FileAccess.WRITE)
	save_file.store_var(Global.username)
	save_file.store_var(Global.player_color)
	save_file.store_var(Global.server_list)
	
	save_file_exists = true
	print("Save game saved!")
	saved_data.emit()
	
func load_data() -> void:
	if not FileAccess.file_exists(OS.get_user_data_dir().path_join(SAVENAME)):
		save_file_exists = false
		print("Save game not found!")
		loaded_data.emit(false)
		return
	var save_file: FileAccess = FileAccess.open(OS.get_user_data_dir().path_join(SAVENAME), FileAccess.READ)
	Global.username = save_file.get_var()
	Global.player_color = save_file.get_var()
	Global.server_list = save_file.get_var()
	
	save_file_exists = true
	print("Save game loaded!")
	loaded_data.emit(true)
