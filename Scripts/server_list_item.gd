class_name ServerListItem
extends HBoxContainer

@export var server_name: String = "Server Name"
@export var server_ip: String = "localhost"
@export var can_edit: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ServerName.text = server_name
	%Edit.disabled = not can_edit
	%Panel.tooltip_text = server_ip


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_join_pressed() -> void:
	MultiplayerSystem.join_server(server_ip)
