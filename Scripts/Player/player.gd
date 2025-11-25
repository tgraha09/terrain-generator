extends CharacterBody3D
@onready var player_model = $Player_model
@onready var anim_player: AnimationPlayer = $Player_model/Player_base/AnimationPlayer
@onready var anim_tree: AnimationTree = $Player_model/Player_base/AnimationTree
@onready var camera = $camera_mount/CameraPivot/Camera3D
@export var blend_speed := 5.0
@export var speed := 1.0
@export var walk_speed_multiplier := 1.0
@export var run_speed_multiplier := 2.0	
var player_logic = MovementLogic
var first_time := false
var current_animation := ""
var current_speed := 0.0


func _ready():
	if not first_time:
		print("Started Player Process")
		# Initialize references FIRST
		anim_tree.active = true
		player_logic.animation_player = anim_player
		player_logic.animation_tree = anim_tree
		player_logic.set("speed", speed)
		player_logic._toggle_conditions({"idle":true})
		player_logic.change_state(player_logic.States.IDLE)
		print("speed ", speed)
		print("blend_speed ", blend_speed)
		player_logic.animation_tree.set("parameters/movement_tree/movement/blend_amount", -1.0)
		
		#player_logic.animation_player.connect("animation_finished", _test)
		#player_logic.animation_player.connect("animation_finished", player_logic._on_animation_finished, 0)
		#if not player_logic.animation_player.is_connected("animation_finished", player_logic._on_animation_finished):
			#player_logic.animation_player.connect("animation_finished", player_logic._on_animation_finished)
			#player_logic._on_animation_finished()
		first_time = true
func _test():
	print("_on_animation_finished")
	

func _physics_process(delta: float):
	# Make player model face the camera's horizontal direction
	if camera && (player_logic.currentState == player_logic.States.RUN || 
	player_logic.currentState == player_logic.States.WALKFORWARD || 
	player_logic.currentState == player_logic.States.WALKBACKWARD):
		# Get the camera's global rotation (yaw only, we don't want to tilt the player)
		var camera_yaw = camera.global_transform.basis.get_euler().y
		# Create a new rotation that only affects the Y axis to keep the player upright
		player_model.rotation.y = lerp_angle(player_model.rotation.y, camera_yaw, delta * 10.0)

	# Process movement with camera-relative direction
	__process_movement(delta)
	move_and_slide()
	
	
func __process_movement(delta: float):
	# Get the input direction in 2D space (Z is forward/backward, X is left/right)
	var input_dir = Vector3(
		Input.get_axis("turn_left", "turn_right"),  # X axis (left/right)
		0,                                          # Y axis (up/down)
		Input.get_axis("forward", "backward")       # Z axis (forward/backward)
	).normalized()  # Normalize to prevent faster diagonal movement

	if input_dir.length() > 0:
		# Get the camera's basis to determine our movement direction
		var camera_basis = camera.global_transform.basis
		var move_direction = camera_basis.z * input_dir.z + camera_basis.x * input_dir.x
		move_direction.y = 0  # Keep movement horizontal
		move_direction = move_direction.normalized()
		
		if player_logic.currentState == player_logic.States.RUN:
			current_speed = lerpf(current_speed, speed * run_speed_multiplier, delta * blend_speed * run_speed_multiplier)    
		else:
			current_speed = lerpf(current_speed, speed * walk_speed_multiplier, delta * blend_speed * walk_speed_multiplier)
		
		velocity = move_direction * current_speed
	else:
		velocity = Vector3.ZERO

	# Rest of your code...
	player_logic.velocity = velocity.length()
	player_logic.handle_states(delta, blend_speed)
