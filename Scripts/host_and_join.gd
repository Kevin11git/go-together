extends Control


const SERVER_LIST_ITEM: PackedScene = preload("res://Scenes/server_list_item.tscn")



var listener: PacketPeerUDP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerSystem.joining_server.connect(_on_server_joining)
	multiplayer.connection_failed.connect(on_connection_failed)
	add_saved_servers()
	setup_listener()

func _process(delta: float) -> void:
	fetch_lan_servers()



func _on_server_joining(server_ip: String):
	%JoiningServerPopup.visible = true
	%JoiningServerDisconnectButton.grab_focus()

func _on_joining_server_disconnect_button_pressed() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	%JoiningServerPopup.visible = false
	%JoiningServerLabel.text = "Joining server..."

func on_connection_failed():
	%JoiningServerLabel.text = "Error: Server connection failed\nIs server the online and are you connected to the internet?"
	

# SERVERS
func add_saved_servers() -> void:
	if Global.server_list.is_empty(): return
	
	for server in Global.server_list:
		var server_list_item: ServerListItem = SERVER_LIST_ITEM.instantiate()
		server_list_item.server_name = server[0]
		server_list_item.server_ip = server[1]
		%ServersServerList.add_child(server_list_item)


func _on_servers_add_server_pressed() -> void:
	%ServersAddServerAdd.disabled = true
	%ServersAddServerServerName.text = "Server"
	%ServersAddServerServerIp.text = ""
	%ServersAddServerPopup.visible = true
	%ServersAddServerServerName.grab_focus()

func _on_servers_direct_connection_pressed() -> void:
	%ServersDirectConnectionPopup.visible = true
	%ServersDirectConnectionServerIp.grab_focus()

# - ServersAddServerPopup
func _on_servers_add_server_add_pressed() -> void:
	%ServersAddServerServerIp.text =  %ServersAddServerServerIp.text.replace(" ", "")
	var server_list_item: ServerListItem = SERVER_LIST_ITEM.instantiate()
	server_list_item.server_name = %ServersAddServerServerName.text
	server_list_item.server_ip = %ServersAddServerServerIp.text
	%ServersServerList.add_child(server_list_item)
	
	%ServersAddServerPopup.visible = false
	
	Global.server_list.append([server_list_item.server_name, server_list_item.server_ip])
	SaveSystem.save_data()

func _on_servers_add_server_cancel_pressed() -> void:
	%ServersAddServerPopup.visible = false

func _on_servers_add_server_server_name_text_changed(new_text: String) -> void:
	if %ServersAddServerServerIp.text.replace(" ", "") == "" or %ServersAddServerServerName.text.replace(" ", "") == "":
		%ServersAddServerAdd.disabled = true
	else:
		%ServersAddServerAdd.disabled = false

func _on_servers_add_server_server_ip_text_changed(new_text: String) -> void:
	if %ServersAddServerServerIp.text.replace(" ", "") == "" or %ServersAddServerServerName.text.replace(" ", "") == "":
		%ServersAddServerAdd.disabled = true
	else:
		%ServersAddServerAdd.disabled = false

# - ServersDirectConnectionPopup
func _on_servers_direct_connection_connect_pressed() -> void:
	MultiplayerSystem.join_server(%ServersDirectConnectionServerIp.text)
	%ServersDirectConnectionPopup.visible = false
	

func _on_servers_direct_connection_cancel_pressed() -> void:
	%ServersDirectConnectionPopup.visible = false

func _on_servers_direct_connection_server_ip_text_changed(new_text: String) -> void:
	if %ServersDirectConnectionServerIp.text.replace(" ", "") == "":
		%ServersDirectConnectionConnect.disabled = true
	else:
		%ServersDirectConnectionConnect.disabled = false


 # LAN
func fetch_lan_servers():
	if listener.get_available_packet_count() > 0:
		var array_bytes = listener.get_packet()
		var data = array_bytes.get_string_from_ascii()
		var json_data = JSON.parse_string(data)
		var server_address: String = listener.get_packet_ip() + ":" + json_data["port"]
		
		var server_list_item: ServerListItem
		if %LANServerList.get_node_or_null(server_address.replace(".", "_").replace(":", "_")) == null:
			server_list_item = SERVER_LIST_ITEM.instantiate()
			server_list_item.server_name = json_data["name"]
			server_list_item.server_ip = server_address
			server_list_item.players_online = json_data["players_count"]
			server_list_item.can_edit = false
			server_list_item.name = server_address
			%LANServerList.add_child(server_list_item)
		else:
			server_list_item = %LANServerList.get_node(server_address.replace(".", "_").replace(":", "_"))
			server_list_item.server_name = json_data["name"]
			server_list_item.server_ip = server_address
			server_list_item.players_online = json_data["players_count"]

func setup_listener():
	listener = PacketPeerUDP.new()
	var error := listener.bind(MultiplayerSystem.listen_port)
	if error == OK:
		print("Bound to listen port successfully! Port: " + str(MultiplayerSystem.listen_port))
	else:
		print("failed to bind listen port")

func _exit_tree() -> void:
	listener.close()


# HOST
func _on_host_host_button_pressed() -> void:
	var port: int = int(%HostPort.text)
	if %HostPort.text.is_empty():
		port = int(%HostPort.placeholder_text)
	
	MultiplayerSystem.host_server(port, int(%HostMaxPlayers.value))

# dont let it use listener or broadcaster port
func _on_host_port_text_changed(new_text: String) -> void:
	%HostHostButton.disabled = new_text == str(MultiplayerSystem.listen_port) or new_text == str(MultiplayerSystem.broadcast_port)


# ADVANCED
func set_username():
	var username: String = $Username.text
	if $Username.text.is_empty():
		username = "Player" + str(multiplayer.get_unique_id()).left($Username.max_length - 6)
	Global.username = username
	

# I DISABLED THIS89378
func _on_ip_of_server_text_changed(new_text: String) -> void:
	if new_text.is_valid_ip_address() or new_text == "localhost" and not $Port.text.is_empty():
		$Join.disabled = false
	else:
		$Join.disabled = true

func _on_join_pressed() -> void:
	var port: String = $TabContainer/Advanced/Port.text
	if $TabContainer/Advanced/Port.text.is_empty():
		port = $TabContainer/Advanced/Port.placeholder_text
	
	MultiplayerSystem.join_server($TabContainer/Advanced/IpOfServer.text + ":" + port)

func _on_host_pressed() -> void:
	# Create server.
	var port: int = int($TabContainer/Advanced/Port.text)
	if $TabContainer/Advanced/Port.text.is_empty():
		port = int($TabContainer/Advanced/Port.placeholder_text)
	
	MultiplayerSystem.host_server(port, int($TabContainer/Advanced/MaxPlayers.value))

# dont let it use listener or broadcaster port
func _on_port_text_changed(new_text: String) -> void:
	$TabContainer/Advanced/Host.disabled = new_text == str(MultiplayerSystem.listen_port) or new_text == str(MultiplayerSystem.broadcast_port)
