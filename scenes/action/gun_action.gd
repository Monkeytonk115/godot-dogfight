extends Node3D

func fire():
	get_node("/root/Main").shoot_bullet_client.rpc($lowResGun/gun_body/gun_barrel.global_transform, -$lowResGun/gun_body/gun_barrel.global_transform.basis.z * 200)
