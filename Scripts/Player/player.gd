extends CharacterBody3D

@onready var anim_player: AnimationPlayer = $visuals/Player_base/AnimationPlayer
@onready var anim_tree: AnimationTree = $visuals/Player_base/AnimationTree

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
	# Get 3D movement input
	var input_dir = Vector3(
		0,  # X axis (left/right)
		0,  # Y axis (up/down - unused for ground movement)
		Input.get_axis("forward", "backward")  # Z axis (forward/backward)
	)
	
	# Normalize and apply speed
	if input_dir.length() > 0:
		if player_logic.currentState == player_logic.States.RUN:
			current_speed = lerpf(current_speed, speed * run_speed_multiplier, delta * blend_speed*run_speed_multiplier)	
		else:
			current_speed = lerpf(current_speed, speed * walk_speed_multiplier, delta * blend_speed*walk_speed_multiplier)
		velocity = input_dir.normalized() * current_speed #normalizes speed in all directions
	else:
		velocity = Vector3.ZERO #sets velocity to zero if no input
	
	if current_speed == speed * run_speed_multiplier || current_speed == speed * walk_speed_multiplier:
		print("Current speed: {current_speed}")
		print("Speed: {speed}")
		print("Run speed multiplier: {run_speed_multiplier}")
		print("Walk speed multiplier: {walk_speed_multiplier}")
	# Update movement logic
	player_logic.velocity = velocity.length()
	player_logic.handle_states(delta, blend_speed)
		
	move_and_slide()
