extends CharacterBody3D

@onready var anim_player: AnimationPlayer = $visuals/Player_base/AnimationPlayer
@onready var anim_tree: AnimationTree = $visuals/Player_base/AnimationTree

@export var blend_speed := 5.0
@export var speed := 5.0

var player_logic = MovementLogic
var first_time := false

func _ready():
	if not first_time:
		print("Started Player Process")
		# Initialize references FIRST
		player_logic.animation_player = anim_player
		player_logic.animation_tree = anim_tree

		# Activate AnimationTree BEFORE setting parameters
		anim_tree.active = true

		# Force initial state (order matters!)
		player_logic.change_state(player_logic.States.IDLE)
		#anim_tree.set("parameters/idle_blend_walk/Walking/blend_amount", 0.0)
		
		# Debug: Print all parameters to verify paths
		
		first_time = true

func _physics_process(delta: float):
	# Get 3D movement input
	var input_dir = Vector3(
		Input.get_axis("left", "right"),  # X axis (left/right)
		0,                                # Y axis (up/down - unused for ground movement)
		Input.get_axis("forward", "backward")  # Z axis (forward/backward)
	)
	
	# Normalize and apply speed
	if input_dir.length() > 0:
		velocity = input_dir.normalized() * speed
	else:
		velocity = Vector3.ZERO
	
	# Update movement logic
	player_logic.velocity = velocity.length()
	player_logic.handle_states(delta, blend_speed)
	
	move_and_slide()
