class_name PlayerJumpState
extends PlayerMovementState

@export var CORNER_SHIFT : WallCollisions

var killed_jump : bool  = false

func enter(previous_state_name : String) -> void:
	PLAYER.velocity.y += PLAYER.JUMP_VELOCITY
	ANIMATED_SPRITE.play("jump")
	killed_jump = false

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
	elif !Input.is_action_pressed("jump") and PLAYER.velocity.y < 0 and !killed_jump:
		PLAYER.velocity.y = 0
		killed_jump = true
	
	elif PLAYER.is_on_floor():
		ANIMATED_SPRITE.play("land")
		transition.emit("PlayerIdleState")
