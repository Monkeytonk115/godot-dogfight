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
	
	for peer_id in multiplayer.get_peers():
		var new_spitfire = SPITFIRE_ACTION.instantiate()
		new_spitfire.set_multiplayer_authority(multiplayer.get_unique_id())
		new_spitfire.set_name("spitfire" + str(multiplayer.get_unique_id()))
		$players.add_child(new_spitfire, true)
		new_spitfire.position = Vector3(300, 300 + (hash(peer_id) % 40), 300)
