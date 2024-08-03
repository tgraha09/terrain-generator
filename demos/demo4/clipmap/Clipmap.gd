extends Node3D

#@onready var player_character:PhysicsBody3D = $PlayerCharacter
@export var player_character:PhysicsBody3D;

func _physics_process(delta):
	global_position	= player_character.global_position.round() * Vector3(1,0,1)
