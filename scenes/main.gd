extends Node3D

const LANDSCAPE_V_1 = preload("res://scenes/world/landscapeV1.tscn")
const SPITFIRE_ACTION = preload("res://scenes/action/spitfire_action.tscn")
const _109E_ACTION = preload("res://scenes/action/109e_action.tscn")

var level = null

func _ready():
	MultiplayerHelper.change_level.connect(change_level)
	MultiplayerHelper.player_change.connect(player_change)


func change_level(new_level):
	$CanvasLayer/MultiplayerMenu.hide()
	print("changing level ", new_level)
	if level:
		level.queue_free()
	level = LANDSCAPE_V_1.instantiate()
	$world.add_child(level)
	level.get_node("SpectateCamera").make_current()
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
		spawn_plane(peer_id)


func spawn_plane(peer_id):
	var new_spitfire = [SPITFIRE_ACTION, _109E_ACTION].pick_random().instantiate()
	new_spitfire.set_multiplayer_authority(peer_id)
	new_spitfire.set_name("spitfire" + str(peer_id))
	$players.add_child(new_spitfire, true)
	# Choose a spawn point
	var points = level.get_node("spawn_points").get_children()
	var point = points[randi_range(0, len(points) - 1)]
	new_spitfire.position = point.global_position + Vector3(0, (hash(peer_id) % 40), 0)
	new_spitfire.rotation = point.rotation
	new_spitfire.crashed.connect(plane_crashed)


func player_change(peer_id, joined):
	spawn_planes()


func plane_crashed(plane : Node, peer_id : int):
	print(plane.name, " crashed")
	plane.queue_free()
	if peer_id == multiplayer.get_unique_id():
		level.get_node("SpectateCamera").make_current()
	get_tree().create_timer(4).timeout.connect(func(): spawn_plane(peer_id))


const bullet = preload("res://scenes/action/bullet.tscn")

@rpc("any_peer", "call_local")
func shoot_bullet_client(origin : Transform3D, velocity : Vector3):
	var new_bullet = bullet.instantiate()
	new_bullet.global_transform = origin
	new_bullet.linear_velocity = velocity
	$bullets.add_child(new_bullet, true)
