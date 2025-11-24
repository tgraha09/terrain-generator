class_name PlayerMovement
extends Node

# Proper type hints
var animation_player: AnimationPlayer
var animation_tree: AnimationTree

enum States {IDLE, RUN, JUMP, WALKFORDWARD, WALKBACKWARD, NONE}
var currentState = States.NONE

# Movement parameters
var velocity := 0.0
var max_walk_speed := 5.0
var blend_speed := 1.0
var delta := 0.0
var speed = 0
const XFADE_TIME = 0.2
const condition_path = "parameters/conditions/"
const movment_blend = "parameters/movement_tree/movement/blend_amount"
var jump_released = true

#speed = speed



func change_state(newState):
	currentState = newState

func handle_states(_delta, _blend_speed):
	delta = _delta
	blend_speed = _blend_speed
	
	match currentState:
		States.IDLE:
			_idle()
		States.WALKFORDWARD:
			_walkForward()
		States.WALKBACKWARD:
			_walkBackward()
		States.RUN:
			_run()
		States.JUMP:
			_jump()
		States.NONE:
			print("NONE")	

func _idle():
	#print("IDLE")
	var current_blend = animation_tree.get(movment_blend)
	#print("Idle: ",current_blend)
	#print("Idle: ",animation_tree.get("parameters/conditions/idle_to_movement"))
	var new_blend = lerpf(current_blend, -1.0, delta * blend_speed*2)
	animation_tree.set(movment_blend, new_blend)
	
	#print("current_blend IDLE: ", current_blend)
	#player_logic.enable_animations({"idle_to_movement":false})
	if Input.is_action_pressed("jump") && jump_released:
		change_state(States.JUMP)
		#_toggle_animations({"jump": true})
		jump_released = false
	if Input.is_action_just_released(("jump")):
		jump_released = true
		print("Jump released")
		#is_jumping = true
	if Input.is_action_pressed("forward"):
		change_state(States.WALKFORDWARD)
	if Input.is_action_pressed("backward"):
		change_state(States.WALKBACKWARD)
		#_toggle_conditions({"walk_backwards": true})
		#animation_tree.set("parameters/conditions/walk_backwards", false)
	


func _walkForward():
	#print("WALK")
	# Only update blend if in transition state
	var current_blend = animation_tree.get(movment_blend)
	#print("Walk: ", current_blend)
	var new_blend = lerpf(current_blend, 0.0, delta * blend_speed*2)
	animation_tree.set(movment_blend, new_blend)
	if Input.is_action_pressed("jump") && jump_released:
		change_state(States.JUMP)
		jump_released = false
		#_toggle_animations({"jump": true})

		#is_jumping = true
	if Input.is_action_just_released("forward"):
		change_state(States.IDLE)
	if Input.is_action_just_released(("jump")):
		jump_released = true
		print("Jump released")
	elif Input.is_action_pressed("forward") && Input.is_action_pressed("shift"):
		change_state(States.RUN)
		speed = speed * 2

func _walkBackward():
	#print("walkBackward")
	_toggle_conditions({"start_walking_back": true})
	animation_tree["parameters/playback"].travel("Walk Backwards", 0.2)
	# Only update blend if in transition state
	#animation_tree.set("parameters/conditions/walk_backwards", false)
	#animation_tree["parameters/playback"].travel("Walk Backwards", 0.1)

	if Input.is_action_pressed("jump")  && jump_released:
		change_state(States.JUMP)
		jump_released = false
		#_toggle_animations({"jump": true})
		
	if Input.is_action_just_released("backward"):
		change_state(States.IDLE)
		_toggle_conditions({"stop_walking_back": true})
		#_toggle_conditions({"stop_walking_back": false})
		#animation_tree.set("parameters/conditions/walk_back", false)
		#animation_tree.set("parameters/conditions/Is_walking_back", true)
		print("Backward released")


func _run():
	var current_blend = animation_tree.get(movment_blend)
	#print("Run: ", current_blend)
	
	var new_blend = lerpf(current_blend, 1.0, delta * blend_speed*6)
	animation_tree.set(movment_blend, new_blend)
	
	if Input.is_action_pressed("jump")  && jump_released:
		change_state(States.JUMP)
		jump_released = false
		#_toggle_animations({"jump": true})
		
		#is_jumping = true
	if Input.is_action_just_released(("jump")):
		jump_released = true
		print("Jump released")
	# Similar to walk but with different blend parameters
	if Input.is_action_just_released("shift"):
		change_state(States.WALKFORDWARD)
	if Input.is_action_just_released("forward") || Input.is_action_just_released("shift"):
		change_state(States.IDLE)
	elif not Input.is_anything_pressed():
		change_state(States.IDLE)

func _jump():
	print("Jump*")
	_toggle_conditions({"jump": true})
	#animation_tree.set("parameters/conditions/jump", true)
	
	animation_tree["parameters/playback"].travel("Jump", 0.2)
	if Input.is_action_pressed("forward"):
		animation_tree.set("parameters/conditions/jump", false)
		change_state(States.WALKFORDWARD if !Input.is_action_pressed("shift") else States.RUN)
	else:
		animation_tree.set("parameters/conditions/jump", false)
		change_state(States.IDLE)
	
	#animation_player.current_animation = "Jump"
	#_on_animation_finished("Jump")
	#animation_player.current_animation

	#if animation_player.is_connected("animation_finished", _on_animation_finished) && animation_player.animation_finished.get_name() == "Jump":
		
		#print("Connected")
		#animation_player.disconnect("animation_finished", _on_animation_finished)
		#animation_player.connect("animation_finished", _on_animation_finished)
	#jump_released = false
	#if not animation_player.is_connected("animation_finished", _on_animation_finished):
		#animation_player.connect("animation_finished", _on_animation_finished)
	# Similar to walk but with different blend parameters
	#if Input.is_action_just_released("shift"):
		#change_state(States.WALKFORDWARD)

	#elif not Input.is_anything_pressed() || Input.is_action_just_released("forward"):
		#change_state(States.IDLE)

func _on_animation_finished(anim_name):
	#print("_on_animation_finished")
	if anim_name == "Jump":
		animation_tree["parameters/playback"].travel("movement_tree", XFADE_TIME)
		_toggle_conditions({"jump": false})
		if Input.is_action_pressed("forward"):
			change_state(States.WALKFORDWARD if !Input.is_action_pressed("shift") else States.RUN)
		else:
			change_state(States.IDLE)

func _transition_to(anim_name: String, new_state: States):
	animation_tree["parameters/playback"].travel(anim_name, XFADE_TIME)
	currentState = new_state

	
func _toggle_conditions(_conditions: Dictionary):
	print("trigger_animations")
	for parameter in animation_tree.get_property_list():
		#print(parameter.name)
		if parameter.name.begins_with(condition_path) && parameter.type == TYPE_BOOL:
			#print(parameter.name)
			for condition in _conditions:
				#print(condition)
				if parameter.name.contains(condition):
					var dict_value = _conditions[condition]
					#print(condition)
					#print(dict_value)
					animation_tree.set(parameter.name, dict_value)
				else:
					animation_tree.set(parameter.name, false)

#func _ready() -> void:
	#animation_player.connect("animation_finished", _on_animation_finished, 0)
