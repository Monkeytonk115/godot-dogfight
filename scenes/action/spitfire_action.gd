extends CharacterBody3D


const SPEED = 30

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _transform_renorm = 0
var free_cam = false
@export var free_cam_angle = TAU * 0.25

var next_fire_time

func _ready():
	if is_multiplayer_authority():
		$Camera3D.make_current()
	next_fire_time = 0

func _process(delta):
	free_cam = Input.is_action_pressed("free_cam")
	if free_cam:
		var cam_input = Input.get_vector("Roll_Left", "Roll_Right", "Pitch_Up", "Pitch_Down")
		free_cam_angle += cam_input.x * delta
	else:
		free_cam_angle = lerpf(free_cam_angle, TAU*0.25, delta)
	
	$Camera3D.position = 15 * Vector3(cos(free_cam_angle), 0, sin(free_cam_angle))
	$Camera3D.transform.basis = Basis.IDENTITY.rotated(Vector3.UP, 0.25*TAU - free_cam_angle)

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	_transform_renorm += delta
	if _transform_renorm > 5:
		transform.basis.orthonormalized()
		_transform_renorm = 0
		
	if Input.is_action_pressed("trigger"):
		var now = Time.get_ticks_msec()
		if next_fire_time < now:
			next_fire_time = now + 100
			for gun in $Guns.get_children():
				gun.fire()

	if not free_cam:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("Roll_Left", "Roll_Right", "Pitch_Up", "Pitch_Down")
		var input_dir2 = Input.get_vector("Yaw_Left", "Yaw_Right", "ui_up", "ui_down")

		velocity = (transform.basis.z * -SPEED)
		#Yaw
		rotate(transform.basis.y, -input_dir2.x * delta)
		#Pitch
		rotate(transform.basis.x, -input_dir.y * delta * 1.5)
		#Roll
		rotate(transform.basis.z, -input_dir.x * delta * 2)

	move_and_slide()
