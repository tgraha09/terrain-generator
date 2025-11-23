extends CharacterBody3D

@onready var anim_player: AnimationPlayer = $visuals/Player_base/AnimationPlayer
@onready var anim_tree: AnimationTree = $visuals/Player_base/AnimationTree

@export var blend_speed := 5.0
@export var speed := 1

var player_logic = MovementLogic
var first_time := false
var current_animation := ""
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
	#if current_animation != player_logic.animation_player.current_animation:
		#current_animation = player_logic.animation_player.current_animation
		
	move_and_slide()
