class_name PlayerJumpState
extends PlayerMovementState

@export var CORNER_SHIFT : WallCollisions

func enter(previous_state_name : String) -> void:
	PLAYER.velocity.y += PLAYER.JUMP_VELOCITY
	ANIMATED_SPRITE.play("jump")

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta)
	PLAYER.update_velocity()
	
	flip_sprite()
	
	check_transitions()

func flip_sprite():
	var input_direction = PLAYER.get_input_direction()
	if input_direction < 0:
		ANIMATED_SPRITE.flip_h = true
	elif input_direction > 0:
		ANIMATED_SPRITE.flip_h = false

func check_transitions():
	if PLAYER.velocity.y > 0:
		transition.emit("PlayerFallState")
	
	# Cut jump short for dynamic jump height
	elif Input.is_action_just_released("jump") and PLAYER.velocity.y < 0:
		PLAYER.velocity.y = 0
	
	elif PLAYER.is_on_floor():
		ANIMATED_SPRITE.play("land")
		transition.emit("PlayerIdleState")
