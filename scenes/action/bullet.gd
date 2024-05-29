extends RigidBody3D


func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1


func _physics_process(_delta):
	if position.y <= -10:
		queue_free()


func _on_body_entered(body):
	print("hit ", body)
	queue_free()
