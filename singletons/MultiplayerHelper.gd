extends Node

signal change_level(new_level)

@onready var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	# Emitted when this MultiplayerAPI's multiplayer_peer successfully connected to a server. Only emitted on clients.
	multiplayer.connected_to_server.connect(connected_to_server)
	
	# Emitted when this MultiplayerAPI's multiplayer_peer fails to establish a connection to a server. Only emitted on clients.
	multiplayer.connection_failed.connect(connection_failed)
	
	# Emitted when this MultiplayerAPI's multiplayer_peer connects with a new peer. ID is the peer ID of the new peer. Clients get notified when other clients connect to the same server. Upon connecting to a server, a client also receives this signal for the server (with ID being 1).
	multiplayer.peer_connected.connect(peer_connected)
	
	# Emitted when this MultiplayerAPI's multiplayer_peer disconnects from a peer. Clients get notified when other clients disconnect from the same server.
	multiplayer.peer_disconnected.connect(peer_disconnected)

func host_game():
	# if not hosting_game():
	enet_peer.create_server(5555)
	multiplayer.multiplayer_peer = enet_peer
	print("hosting")

func join_game(remote_addr):
	enet_peer.create_client(remote_addr, 5555)
	multiplayer.multiplayer_peer = enet_peer
	print("joining")

func connected_to_server():
	print("connected to server")

func connection_failed():
	print("connection failed")

func peer_connected(peer_id):
	print("new peer connected: ", peer_id)
	if multiplayer.get_unique_id() == 1:
		_change_level_helper.rpc("landscape_v1")

@rpc("authority", "call_local")
func _change_level_helper(new_level):
	change_level.emit(new_level)

func peer_disconnected(peer_id):
	print("peer disconnected: ", peer_id)
