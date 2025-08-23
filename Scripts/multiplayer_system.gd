extends Node


var peer = WebSocketMultiplayerPeer.new()
var client_ip: String = ""
var client_port: int = 0
var host_port: int = 0

var listen_port: int = 43435
var broadcast_port: int = 43434
var broadcast_timer: Timer
var broadcaster: PacketPeerUDP

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
	print("ws://" + client_ip + ":" + str(client_port) + "/")
	var error := peer.create_client("ws://" + client_ip + ":" + str(client_port) + "/")
	multiplayer.multiplayer_peer = peer
	

func host_server(port: int, max_players: int) -> void:
	# Create server
	host_port = port
	print("hosting server with port: " + str(port) + " and max players: " + str(max_players))
	hosted_server.emit(port)
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	
	
	var ip_adress :String

	if OS.has_feature("windows"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	print(ip_adress)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
	setup_broadcast()
	
func setup_broadcast():
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	
	var broadcast_ip := "192.168.19.255"
	if OS.has_feature("windows"):
		var host_ip = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
		broadcast_ip =  "192.168." + host_ip.split(".")[2] + ".255"
	
	broadcaster.set_dest_address(broadcast_ip, listen_port)
	var error := broadcaster.bind(broadcast_port)
	if error == OK:
		print("Bound to broadcast port successfully! Port: " + str(broadcast_port) + ". Ip range: " + broadcast_ip)
	else:
		print("failed to bind broadcast port")
	broadcast_timer = Timer.new()
	broadcast_timer.name = "BroadcastTimer"
	broadcast_timer.wait_time = 1
	broadcast_timer.timeout.connect(on_broadcast_timer_timeout)
	add_child(broadcast_timer)
	broadcast_timer.start()

func on_broadcast_timer_timeout():
	var data := {
		"name": Global.username + "'s Server",
		"players_count": multiplayer.get_peers().size() + 1,
		"port": str(host_port)
	}
	var json_data := JSON.stringify(data)
	var packet := json_data.to_ascii_buffer()
	broadcaster.put_packet(packet)

func _exit_tree() -> void:
	if broadcaster != null: broadcaster.close()
	broadcast_timer.stop()
