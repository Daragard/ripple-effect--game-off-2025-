class_name PlayerJumpState
extends PlayerMovementState

func enter(previous_state_name : String) -> void:
	PLAYER.velocity.y += PLAYER.JUMP_VELOCITY
	ANIMATED_SPRITE.play("jump")
	print("enter jump")

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta)
	PLAYER.update_velocity()
	
	var input_direction = PLAYER.get_input_direction()
	if input_direction < 0:
		ANIMATED_SPRITE.flip_h = true
	else:
		ANIMATED_SPRITE.flip_h = false
	
	if PLAYER.velocity.y > 0:
		transition.emit("PlayerFallState")
	
	# Cut jump short for dynamic jump height
	elif Input.is_action_just_released("jump") and PLAYER.velocity.y < 0:
		PLAYER.velocity.y = 0
	
	elif PLAYER.is_on_floor():
		ANIMATED_SPRITE.play("land")
		transition.emit("PlayerIdleState")
