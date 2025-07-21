#extends CharacterBody3D
extends Node

class_name PlayerMovement

var animation_player: AnimationPlayer = null
#var animation_player: AnimationPlayer

func _play(_name: String, val: bool):
	if animation_player == null or not animation_player.has_animation(_name):
		return
	if val:
		animation_player.play(_name)
	else:
		animation_player.stop()

func _ready():
	print("Player Movement Ready")
