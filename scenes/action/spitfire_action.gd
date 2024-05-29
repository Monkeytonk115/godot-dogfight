extends CharacterBody3D


const SPEED = 30

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Roll_Left", "Roll_Right", "Pitch_Up", "Pitch_Down")
	var input_dir2 = Input.get_vector("Yaw_Left", "Yaw_Right", "ui_up", "ui_down")
	
	velocity = (transform.basis.z * -SPEED)
	#Yaw
	rotate(transform.basis.y, -input_dir2.x * delta)
	#Pitch
	rotate(transform.basis.x, input_dir.y * delta * 1.5)
	#Roll
	rotate(transform.basis.z, -input_dir.x * delta * 2)
	
	

	move_and_slide()
