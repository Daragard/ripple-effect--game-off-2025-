class_name BigBomb
extends Node2D

@export var ATTRACTION_BOMB : bool = false
@export var EXPLOSION_FORCE = 10000
@onready var ANIMATION_STARTER : AnimationPlayer = $AnimationStarter
@onready var ANIMATION_1 : AnimationPlayer = $AnimationPlayer
@onready var ANIMATION_2 : AnimationPlayer = $AnimationPlayer2
@onready var ANIMATION_3 : AnimationPlayer = $AnimationPlayer3
@onready var COOLDOWN : Timer = $Cooldown

var PLAYER : Player
var can_throw_bomb : bool = true
var player_in_radius : bool = false

func _ready() -> void:
	var scene_root = owner 
	
	if scene_root:
		# Search the children of the scene root for a node that has the 'Player' class_name
		for child in scene_root.get_children():
			# Check if the child is a valid object AND has the class_name "Player"
			if is_instance_valid(child) and child is Player:
				# Save the instance to the exported variable
				PLAYER = child
				break # Stop searching once the Player is found
	else:
		push_warning("Warning: WaveBomb could not find the scene owner (root).")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_radius and COOLDOWN.is_stopped():
		blow_up()

func blow_up():
	print("Wish I had an explosion animation")
	
	var direction_to_player = global_position.direction_to(PLAYER.global_position)
	
	if !ATTRACTION_BOMB:
		PLAYER.velocity = direction_to_player * EXPLOSION_FORCE
	else:
		PLAYER.velocity = -direction_to_player * EXPLOSION_FORCE
	
	COOLDOWN.start()

func _on_explosion_radius_body_entered(body: Node2D) -> void:
	player_in_radius = true

func _on_explosion_radius_body_exited(body: Node2D) -> void:
	player_in_radius = false

func _on_effect_animation_finished() -> void:
	if player_in_radius:
		ANIMATION_STARTER.play("starter")

func _on_cooldown_timeout() -> void:
	ANIMATION_STARTER.play("starter")
