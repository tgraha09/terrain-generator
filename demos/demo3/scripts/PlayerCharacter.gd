extends CharacterBody3D

@export var speed = 10.0
@export var jump_velocity = 4.5
@onready var cameraFirstPerson:Camera3D = $CameraFP
@onready var cameraThirdPerson:Camera3D = $CameraTP
@onready var camera_display:Camera3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity_y = 0.0
var camera_changed = false
var look_sensitivity = ProjectSettings.get_setting("player/look_sensitivity")

func _ready():
	camera_display = cameraFirstPerson

func _physics_process(delta):
	var horizontal_velocity = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized() * speed
	velocity = horizontal_velocity.x * transform.basis.x + horizontal_velocity.y * transform.basis.z
	if is_on_floor():
		velocity_y = 0
		if Input.is_action_just_pressed("player_jump"): 
			##print("jump")
			velocity_y = jump_velocity
			
	else:
		velocity_y -= gravity * delta
	velocity.y = velocity_y
	move_and_slide()
	if Input.is_action_just_pressed("ui_cancel"): 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

func _input(event):

	if Input.is_action_just_pressed("change_camera"):
		print(camera_changed)
		toggleCamera()
	if event is InputEventMouseMotion:
		if camera_changed==false:
			camera_display.rotate_x(-event.relative.y * look_sensitivity)
			camera_display.rotation.x = clamp(camera_display.rotation.x, -PI/2, PI/2)	
		rotate_y(-event.relative.x * look_sensitivity)
		
		
func toggleCamera():
	camera_changed = !camera_changed
	if camera_changed:
		cameraFirstPerson.current = false
		cameraThirdPerson.current = true
		camera_display = cameraThirdPerson
	else:
		cameraFirstPerson.current = true
		cameraThirdPerson.current = false
		camera_display = cameraFirstPerson
		
