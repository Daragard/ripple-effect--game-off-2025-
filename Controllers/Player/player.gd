class_name Player
extends CharacterBody2D

@export var SPEED : float = 500.0
@export var ACCELERATION : float = 500.0
@export var DECELERATION : float = 1200.0
@export var JUMP_VELOCITY : float = -400.0
@export var WALL_JUMP_LEAP : float = 400.0

@export var STATE_MACHINE : StateMachine
@export var ANIMATED_SPRITE : AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func update_gravity(delta) -> void:
	if !is_on_floor():
		if velocity.y <= 0:
			velocity.y += gravity * delta
		else:
			velocity.y += gravity * 2 * delta
	
# This function handles player input and calculates the movement velocity
# based on the current active camera's direction.
func update_input(delta: float) -> void:
	# Get input vector for horizontal movement.
	var direction = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

# This function handles the physics updates, including rotating the player
# to face their direction of travel and then applying the movement.
func update_velocity() -> void:
	# Rotate the player in the direction of their velocity.
	# We only do this if there is actual movement to avoid snapping to a
	# default direction when the player is idle.
	move_and_slide()

func get_wall_direction() -> int:
	# Get Wall Direction
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var wall_normal = collision.get_normal()
		
		if wall_normal.x > 0.1:
			ANIMATED_SPRITE.flip_h = true
			return -1
		elif wall_normal.x < -0.1:
			ANIMATED_SPRITE.flip_h = false
			return 1
	
	return 0

func get_input_direction():
	var player_input : float = Input.get_axis("left", "right")
	
	if player_input > 0:
		return 1
	elif player_input < 0:
		return -1
	else: 
		return 0
