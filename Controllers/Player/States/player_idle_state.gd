class_name PlayerIdleState
extends PlayerMovementState

@export var JUMP_BUFFER : JumpBuffer
@export var COYOTE_TIMER : PlayerFallState

func enter(previous_state_name : String) -> void:
	if previous_state_name == "PlayerJumpState":
		await ANIMATED_SPRITE.animation_finished
	
	ANIMATED_SPRITE.play("idle")

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta)
	PLAYER.update_velocity()
	
	if JUMP_BUFFER.has_jumped and PLAYER.is_on_floor():
		transition.emit("PlayerJumpState")
		
	elif PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("PlayerRunState")
		
	elif PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		COYOTE_TIMER.coyote_start()
		transition.emit("PlayerFallState")
