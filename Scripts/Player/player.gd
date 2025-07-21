extends CharacterBody3D
#extends PlayerMovement #"res://Scripts/Player/player_movement.gd"
@onready var anim_player: AnimationPlayer = $visuals/Player_model/AnimationPlayer
#var player_movement: PlayerMovement
#var anim_player = player_movement.animation_player
#@onready var player_model: Node3D = $visuals/Player_model
var animtation = MovementLogic


var first_time = false


func _ready():
	if first_time==false:
		print("Started Player Process")
		animtation.set("animation_player", anim_player)
		animtation._play("Idle", true)
		first_time = true
	


#func _process(delta: float) -> void:
	#Movement._playAnimation("Idle", true)
	#PlayerMovement._playAnimation("Idle", true)
	#PlayerMovement._playAnimation("Idle", true)
		#player_movement._playAnimation("Idle", true)
	#if first_time==true:
		#animation_player.play("Idle")
	
