class_name PlayerRunState
extends PlayerMovementState

@export var JUMP_BUFFER : JumpBuffer
@export var COYOTE_TIMER : PlayerFallState

func enter(previous_state_name : String) -> void:
	ANIMATED_SPRITE.play("run")

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta)
	
	var positive_input : bool = Input.get_axis("left", "right") > 0
	var positive_velocity : bool = PLAYER.velocity.x > 0
	
	if positive_input != positive_velocity:
		PLAYER.velocity.x /= 2
	
	PLAYER.update_velocity()
	
	if PLAYER.velocity.x < 0:
		ANIMATED_SPRITE.flip_h = true
	elif PLAYER.velocity.x > 0:
		ANIMATED_SPRITE.flip_h = false
	
	if JUMP_BUFFER.has_jumped and PLAYER.is_on_floor():
		transition.emit("PlayerJumpState")
	
	elif PLAYER.velocity.length() == 0.0:
		transition.emit("PlayerIdleState")
	
	elif !PLAYER.is_on_floor():
		COYOTE_TIMER.coyote_start()
		transition.emit("PlayerFallingState")
