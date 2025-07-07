class_name Chat
extends Control

var is_open: bool = false
var chat_show_tween: Tween

func _ready() -> void:
	Global.game_chat = self
	%LineEdit.visible = is_open
	%ItemList.visible = is_open
	%NewMessagesList.visible = false
	%NewMessagesList.self_modulate.a = 0.0

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("open_chat"): return
	
	is_open = not is_open
	%LineEdit.visible = is_open
	%ItemList.visible = is_open
	%NewMessagesList.visible = not is_open
	
	await get_tree().process_frame
	if is_open:
		%LineEdit.grab_focus()
	elif not %LineEdit.text.is_empty():
		send_message.rpc(Global.username + ": " + %LineEdit.text)
		%LineEdit.text = ""

@rpc("any_peer", "call_local", "reliable")
func send_message(message: String, color: Color = Color.WHITE):
	
	%ItemList.add_item(message)
	%NewMessagesList.add_item(message)
	if color != Color.WHITE:
		%ItemList.set_item_custom_fg_color(%ItemList.item_count - 1, color)
		%NewMessagesList.set_item_custom_fg_color(%NewMessagesList.item_count - 1, color)
	
	if not is_open:
		if chat_show_tween != null and chat_show_tween.is_running():
			chat_show_tween.stop()
		%NewMessagesList.visible = true
		%NewMessagesList.self_modulate.a = 1.0
		
		chat_show_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		chat_show_tween.tween_property(%NewMessagesList, "self_modulate:a", 0.0, 1).set_delay(3)
		chat_show_tween.tween_callback(%NewMessagesList.hide)
		chat_show_tween.tween_callback(%NewMessagesList.clear)
