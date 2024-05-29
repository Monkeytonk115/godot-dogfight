extends Node3D

const LANDSCAPE_V_1 = preload("res://scenes/world/landscapeV1.tscn")
const SPITFIRE_ACTION = preload("res://scenes/action/spitfire_action.tscn")

func _ready():
	MultiplayerHelper.change_level.connect(change_level)
	MultiplayerHelper.player_change.connect(player_change)


func change_level(new_level):
	$CanvasLayer/MultiplayerMenu.hide()
	print("changing level ", new_level)
	var new_landscape = LANDSCAPE_V_1.instantiate()
	$world.add_child(new_landscape)
	spawn_planes()

func spawn_planes():
	var all_player_ids = multiplayer.get_peers()
	all_player_ids.append(multiplayer.get_unique_id())

	# spawn a plane for all peers
	for peer_id in all_player_ids:
		var ply_node = get_node_or_null("players/spitfire" + str(peer_id))
		if ply_node:
			print("player ", peer_id, " has plane already")
			continue
		var new_spitfire = SPITFIRE_ACTION.instantiate()
		new_spitfire.set_multiplayer_authority(peer_id)
		new_spitfire.set_name("spitfire" + str(peer_id))
		$players.add_child(new_spitfire, true)
		new_spitfire.position = Vector3(300, 300 + (hash(peer_id) % 40), 300)

func player_change(peer_id, joined):
	spawn_planes()
