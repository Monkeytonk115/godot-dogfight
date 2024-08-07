extends CharacterBody3D

signal crashed

@export var SPEED = 50
var TAS = 0
var old_pos = Vector3(0,0,0)
var cumulativeTime = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var _transform_renorm = 0
var free_cam = false
@export var free_cam_angle = TAU * 0.25
@export var max_engine_power = 760000 #Watts
@export var take_off_weight = 3048 #Kilograms
@export var wing_lift = 500

var engine_force = Vector3.ZERO
var air_resistance_force = Vector3.ZERO
var lift_force = Vector3.ZERO
var gravity_force = Vector3.ZERO

var next_fire_time

var angular_velocity = Vector3.ZERO
var angular_acceleration = Vector3.ZERO

func _ready():
	if is_multiplayer_authority():
		$Camera3D.make_current()
	next_fire_time = 0
	DebugOverlay.add_property(self, "engine_force", "")
	DebugOverlay.add_property(self, "air_resistance_force", "")
	DebugOverlay.add_property(self, "lift_force", "")
	DebugOverlay.add_property(self, "gravity_force", "")
	DebugOverlay.add_property(self, "velocity", "length")
	
	var old_pos = global_position
	
	

func _process(delta):
	free_cam = Input.is_action_pressed("free_cam")
	if free_cam:
		var cam_input = Input.get_vector("Roll_Left", "Roll_Right", "Pitch_Up", "Pitch_Down")
		free_cam_angle += cam_input.x * delta
	else:
		pass
		#free_cam_angle = lerpf(free_cam_angle, TAU*0.25, delta)
	
	$Camera3D.position = 15 * Vector3(cos(free_cam_angle), 0, sin(free_cam_angle))
	$Camera3D.transform.basis = Basis.IDENTITY.rotated(Vector3.UP, 0.25*TAU - free_cam_angle)
	
	var mesh = (DebugOverlay.mesh as ImmediateMesh)
	mesh.clear_surfaces()

	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(Color.RED)
	mesh.surface_add_vertex(global_transform.origin)
	mesh.surface_add_vertex(global_transform.origin + engine_force)
	mesh.surface_end()
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(Color.RED)
	mesh.surface_add_vertex(global_transform.origin)
	mesh.surface_add_vertex(global_transform.origin + air_resistance_force)
	mesh.surface_end()
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(Color.RED)
	mesh.surface_add_vertex(global_transform.origin)
	mesh.surface_add_vertex(global_transform.origin + lift_force)
	mesh.surface_end()
	
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(Color.RED)
	mesh.surface_add_vertex(global_transform.origin)
	mesh.surface_add_vertex(global_transform.origin + gravity_force)
	mesh.surface_end()

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
				
	
	cumulativeTime = cumulativeTime + delta
	
	if cumulativeTime > 1.0:
		TAS = old_pos.distance_to(global_position) * 3.6
		old_pos = global_position
		cumulativeTime = 0
	
		$Camera3D/CanvasLayer/Label.set_text("TAS: " + str(round(TAS)) + " Km/h")

	if not free_cam:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("Roll_Left", "Roll_Right", "Pitch_Up", "Pitch_Down")
		var input_dir2 = Input.get_vector("Yaw_Left", "Yaw_Right", "ui_up", "ui_down")
		angular_acceleration = Vector3(
			#Clamped input_dir.y to reflect the asymmetrical nature of possible G forces
			clamp(-input_dir.y, -0.25, 1) * delta * 0.7,
			
			-input_dir2.x * delta * 0.2,
			
			-input_dir.x * delta * 1.25
		)

	# forces acting on the plane
	engine_force = (transform.basis.z * -SPEED * take_off_weight) # engine thrust
	air_resistance_force = (-velocity * velocity.length_squared()) # air resistance
	lift_force = (transform.basis.y * wing_lift * (velocity.dot(-transform.basis.z.normalized()))) # wing lift
	gravity_force = Vector3(0, -gravity * take_off_weight, 0) # Gravity

	velocity += (engine_force + air_resistance_force + lift_force + gravity_force) / take_off_weight
	angular_velocity += angular_acceleration
	
	# Angular damping
	angular_velocity *= 0.98
	
	# Apply angular velocity rotations
	rotate(transform.basis.y, angular_velocity.y * delta) # Yaw
	rotate(transform.basis.x, angular_velocity.x * delta) # Pitch
	rotate(transform.basis.z, angular_velocity.z * delta) # Roll

	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		$MultiplayerSynchronizer.queue_free()
		_crashed_helper.rpc()


@rpc("authority", "call_local")
func _crashed_helper():
	crashed.emit(self, get_multiplayer_authority())
	DebugOverlay.remove_property(self, "engine_force")
	DebugOverlay.remove_property(self, "air_resistance_force")
	DebugOverlay.remove_property(self, "lift_force")
	DebugOverlay.remove_property(self, "gravity_force")
	DebugOverlay.remove_property(self, "velocity")
