extends Node3D

const LANDSCAPE_V_1 = preload("res://scenes/world/landscapeV1.tscn")
const SPITFIRE_ACTION = preload("res://scenes/action/spitfire_action.tscn")

func _ready():
	MultiplayerHelper.change_level.connect(change_level)


func change_level(new_level):
	$CanvasLayer/MultiplayerMenu.hide()
	print("changing level ", new_level)
	var new_landscape = LANDSCAPE_V_1.instantiate()
	$world.add_child(new_landscape)
	
	# On server, spawn multiple planes
	if multiplayer.get_unique_id() == 1:
		# spawn the server plane
		var new_spitfire = SPITFIRE_ACTION.instantiate()
		new_spitfire.set_multiplayer_authority(1)
		new_spitfire.set_name("spitfire" + str(1))
		$players.add_child(new_spitfire, true)
		new_spitfire.position = Vector3(300, 300 + (hash(1) % 40), 300)
			
		# spawn the other planes
		for peer_id in multiplayer.get_peers():
			new_spitfire = SPITFIRE_ACTION.instantiate()
			new_spitfire.set_multiplayer_authority(peer_id)
			new_spitfire.set_name("spitfire" + str(peer_id))
			$players.add_child(new_spitfire, true)
			new_spitfire.position = Vector3(300, 300 + (hash(peer_id) % 40), 300)
