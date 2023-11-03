extends CharacterBody3D

@onready var camera_rig = $CameraRig
@onready var camera = $CameraRig/Camera3D

@export var walk_speed = 5.0
@export var sprint_speed = 25.0
@export var jump_speed = 4.5
@export var mouse_sensitivity = 1.0

var curr_speed = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		camera_rig.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	if event.is_action_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	
	if Input.is_action_pressed("sprint") and is_on_floor():
		curr_speed = sprint_speed
	else:
		curr_speed = walk_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (camera_rig.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * curr_speed
		velocity.z = direction.z * curr_speed
	else:
		velocity.x = move_toward(velocity.x, 0, curr_speed)
		velocity.z = move_toward(velocity.z, 0, curr_speed)

	move_and_slide()
