extends Node


var username: String = ""
var player_color: Color = Color.WHITE
var server_list: Array[Array] = []
var mechanics: Array[String] = []:
	set(value):
		mechanics = value
		mechanics_changed.emit()

var game_chat: Chat = null

signal mechanics_changed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen") and OS.has_feature("windows"):
		if get_viewport().get_window().mode == Window.MODE_FULLSCREEN:
			get_viewport().get_window().mode = Window.MODE_WINDOWED
		else:
			get_viewport().get_window().mode = Window.MODE_FULLSCREEN
