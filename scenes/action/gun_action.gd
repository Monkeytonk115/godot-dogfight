extends Node3D

func fire():
	get_node("/root/Main").shoot_bullet_client.rpc($"Bullet spawn".global_transform, -$"Bullet spawn".global_transform.basis.z * 100)
