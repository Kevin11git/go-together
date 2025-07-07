extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveSystem.save_file_exists:
		%Username.text = Global.username
		%PlayerColorPicker.color = Global.player_color
		update_player_color_button_color()

func _on_multiplayer_button_pressed() -> void:
	SaveSystem.save_data()
	get_tree().change_scene_to_file("res://Scenes/host_and_join.tscn")

func _on_player_color_button_pressed() -> void:
	%PlayerColorPicker.visible = not %PlayerColorPicker.visible
	SaveSystem.save_data()


func _on_player_color_picker_color_changed(color: Color) -> void:
	Global.player_color = color
	update_player_color_button_color()

func update_player_color_button_color() -> void:
	%PlayerColorButton.add_theme_color_override("icon_disabled_color", Global.player_color)
	%PlayerColorButton.add_theme_color_override("icon_hover_pressed_color", Global.player_color)
	%PlayerColorButton.add_theme_color_override("icon_hover_color", Global.player_color)
	%PlayerColorButton.add_theme_color_override("icon_pressed_color", Global.player_color)
	%PlayerColorButton.add_theme_color_override("icon_focus_color", Global.player_color)
	%PlayerColorButton.add_theme_color_override("icon_normal_color", Global.player_color)

func _on_username_text_changed(new_text: String) -> void:
	Global.username = %Username.text
	SaveSystem.save_data()


func _on_play_button_pressed() -> void:
	SaveSystem.save_data()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
