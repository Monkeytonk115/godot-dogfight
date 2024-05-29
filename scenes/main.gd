extends Node3D

const LANDSCAPE_V_1 = preload("res://scenes/world/landscapeV1.tscn")
const SPITFIRE_ACTION = preload("res://scenes/action/spitfire_action.tscn")

func _ready():
	var new_landscape = LANDSCAPE_V_1.instantiate()
	$world.add_child(new_landscape)
	var new_spitfire = SPITFIRE_ACTION.instantiate()
	$players.add_child(new_spitfire)
	new_spitfire.position = Vector3(300, 300, 300)
