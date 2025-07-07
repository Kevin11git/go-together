extends Node


var peer = ENetMultiplayerPeer.new()
var client_ip: String = ""
var client_port: int = 0
var host_port: int = 0

signal joining_server(server_ip: String)
signal hosted_server(server_port: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.connected_to_server.connect(on_server_connected)
	multiplayer.connection_failed.connect(on_connection_failed)

func on_server_connected():
	print("Successfully joined server: " + client_ip + ":" + str(client_port))
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
func on_connection_failed():
	print("Failed to join server: " + client_ip + ":" + str(client_port))

func join_server(server_ip: String) -> void:
	var port: int = 55555
	var ip: String = server_ip
	# Server ip can have both port an ip in the same string
	# like 192.168.1.1:55555
	if ":" in server_ip:
		port = int(server_ip.split(":")[1])
		ip = server_ip.split(":")[0]
	
	# Create client.
	client_ip = ip
	client_port = port
	
	print("Joining server: " + client_ip + ":" + str(client_port))
	joining_server.emit(client_ip + ":" + str(client_port))
	peer.create_client(client_ip, client_port)
	multiplayer.multiplayer_peer = peer

func host_server(port: int, max_players: int) -> void:
	# Create server
	print("hosting server with port: " + str(port) + " and max players: " + str(max_players))
	hosted_server.emit(port)
	peer.create_server(port, max_players)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
