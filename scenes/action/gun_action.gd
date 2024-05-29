extends Node3D

func fire():
	get_node("/root/Main").shoot_bullet_client.rpc($bulletSpawn.global_transform, -$bulletSpawn.global_transform.basis.z * 100)
