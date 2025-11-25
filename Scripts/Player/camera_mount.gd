extends Node3D

@onready var camera = $CameraPivot/Camera3D
@onready var camera_pivot = $CameraPivot
@onready var collision_shape = $Player/CollisionShape3D
# Camera settings
@export var mouse_sensitivity := 0.002
@export var max_vertical_angle := deg_to_rad(20)  # 80 degrees in radians
@export var min_vertical_angle := deg_to_rad(-70)  # -30 degrees in radians

# Zoom settings
@export var min_distance := 3.0
@export var max_distance := 10.0
@export var zoom_speed := 5.0
@export var zoom_step := 0.5

var current_distance := 5.0
var target_distance := 5.0  # Target distance for smooth zooming
var rotation_h := 0.0  # Horizontal rotation
var rotation_v := 0.0  # Vertical rotation

func _ready():
	# Set initial camera position
	update_camera_position()
	print("Collision shape found:", collision_shape != null)
	if collision_shape:
		print("Collision shape type:", collision_shape.shape)
	# Make sure the mouse is captured and hidden
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate camera with mouse movement
		rotation_h -= event.relative.x * mouse_sensitivity
		rotation_v -= event.relative.y * mouse_sensitivity
		rotation_v = clamp(rotation_v, min_vertical_angle, max_vertical_angle)
		
		rotation.y = rotation_h
		camera_pivot.rotation.x = rotation_v
		
		update_camera_position()
	
	# Toggle mouse capture with Escape key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	# Handle mouse wheel input directly
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			target_distance = clamp(target_distance - zoom_step, min_distance, max_distance)
			#print("Zoom in")
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			target_distance = clamp(target_distance + zoom_step, min_distance, max_distance)
			#print("Zoom out")

func _process(delta):
	# Smooth zooming
	if abs(current_distance - target_distance) > 0.01:
		current_distance = lerp(current_distance, target_distance, zoom_speed * delta)
		update_camera_position()

func update_camera_position():
	if camera_pivot:
		var camera_height = 1.8  # Default height if no collision shape is found
		
		if collision_shape and collision_shape.shape is BoxShape3D:
			camera_height = collision_shape.shape.size.y * collision_shape.scale.y
			#print("Using collision shape height:", camera_height)
		
		camera.position = Vector3(0, camera_height * 0.9, current_distance)  # 90% of height for eye level

# Call this method to reset the camera's target distance (useful for cutscenes or resets)
func reset_camera_distance():
	target_distance = 5.0
	current_distance = 5.0
	update_camera_position()
