extends Node2D

const PLAYERSCENE: PackedScene = preload("res://Scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.get_unique_id() == 1:
		add_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(add_player)


func add_player(peer_id: int) -> Player:
	var player: Player = PLAYERSCENE.instantiate() as Player
	player.name = str(peer_id)
	add_child(player)
	return player
