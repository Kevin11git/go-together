extends Node


var username: String = ""
var player_color: Color = Color.WHITE
var server_list: Array[Array] = []
var mechanics: Array[String] = []

var game_chat: Chat = null

signal mechanic_added(mechanic: String)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen") and OS.has_feature("windows"):
		if get_viewport().get_window().mode == Window.MODE_FULLSCREEN:
			get_viewport().get_window().mode = Window.MODE_WINDOWED
		else:
			get_viewport().get_window().mode = Window.MODE_FULLSCREEN
