class_name PlayerMovement
extends Node

# Proper type hints
var animation_player: AnimationPlayer
var animation_tree: AnimationTree

enum States {IDLE, RUN, JUMP, WALK, NONE}
var currentState = States.NONE

# Movement parameters
var velocity := 0.0
var max_walk_speed := 5.0
var blend_speed := 1.0
var delta := 0.0
var speed = 0
const condition_path = "parameters/conditions/"
func change_state(newState):
	currentState = newState

func handle_states(_delta, _blend_speed):
	delta = _delta
	blend_speed = _blend_speed
	
	match currentState:
		States.IDLE:
			_idle()
		States.WALK:
			_walk()
		States.RUN:
			_run()

func _idle():
	#print("IDLE")
	var current_blend = animation_tree.get("parameters/idle_blend_walk/Walking/blend_amount")
	var new_blend = lerpf(current_blend, 0.0, delta * blend_speed*2.0)
	animation_tree.set("parameters/idle_blend_walk/Walking/blend_amount", new_blend)
	#print("current_blend IDLE: ", current_blend)

	if Input.is_action_pressed("forward"):
		change_state(States.WALK)
		animation_tree["parameters/playback"].travel("Walking")
		#animation_tree.set("parameters/conditions/idle_to_walk", true)
	


func _walk():
	print("WALK")
	# Only update blend if in transition state
	var current_blend = animation_tree.get("parameters/idle_blend_walk/Walking/blend_amount")
	var new_blend = lerpf(current_blend, 1.0, delta * blend_speed)
	animation_tree.set("parameters/idle_blend_walk/Walking/blend_amount", new_blend)
	
	if Input.is_action_just_released("forward"):
		change_state(States.IDLE)
		#animation_tree.set("parameters/conditions/walk_to_idle", true)
		animation_tree["parameters/playback"].travel("Idle")

func _run():
	# Similar to walk but with different blend parameters
	if Input.is_action_just_released("shift"):
		change_state(States.WALK)
	elif not Input.is_anything_pressed():
		change_state(States.IDLE)
		
func trigger_animations(_conditions: Dictionary):
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
			#		animation_tree.set(parameter.name, true)
					#print(parameter.name)
					#print(true)
				#else:
					#animation_tree.set(parameter.name, false)
					#print(false)
