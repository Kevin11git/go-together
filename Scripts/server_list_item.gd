class_name ServerListItem
extends HBoxContainer

@export var server_name: String = "Server Name"
@export var server_ip: String = "localhost"
@export var can_edit: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ServerName.text = server_name
	%ServerNamePanel.tooltip_text = server_ip
	%Edit.disabled = not can_edit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_join_pressed() -> void:
	MultiplayerSystem.join_server(server_ip)


func _on_edit_pressed() -> void:
	%EditUpdateButton.disabled = true
	%EditServerName.text = server_name
	%EditServerIp.text = server_ip
	update_edit_delete_button_disabled()
	%EditPopup.show()
	%EditServerName.grab_focus()
	


# EDIT POPUP
func update_edit_delete_button_disabled():
	if %EditServerIp.text.replace(" ", "") == "" or %EditServerName.text.replace(" ", "") == "":
		%EditUpdateButton.disabled = true
	else:
		%EditUpdateButton.disabled = false

func _on_edit_cancel_button_pressed() -> void:
	%EditPopup.hide()


func _on_edit_update_button_pressed() -> void:
	var list_item_index: int = get_parent().get_children().find(self) - 1
	server_name = %EditServerName.text
	server_ip = %EditServerIp.text
	server_ip = server_ip.replace(" ", "")
	%ServerName.text = server_name
	%ServerNamePanel.tooltip_text = server_ip
	Global.server_list[list_item_index] = [server_name, server_ip]
	SaveSystem.save_data()
	%EditPopup.hide()


func _on_edit_delete_button_pressed() -> void:
	var list_item_index: int = get_parent().get_children().find(self) - 1
	Global.server_list.remove_at(list_item_index)
	SaveSystem.save_data()
	queue_free()


func _on_edit_server_name_or_ip_text_changed(new_text: String) -> void:
	update_edit_delete_button_disabled()
