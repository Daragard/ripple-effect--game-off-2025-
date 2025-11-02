class_name PlayerFallState

extends PlayerMovementState

@export var WALL_COLLISIONS : WallCollisions
@export var JUMP_BUFFER : JumpBuffer
@onready var TIMER : Timer = $"."
var coyote_jump = false

func enter(previous_state_name : String) -> void:
	ANIMATED_SPRITE.play("fall")

func coyote_start():
	#print("start coyote timer")
	TIMER.start()
	coyote_jump = true

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta)
	PLAYER.update_velocity()
	
	var input_direction = PLAYER.get_input_direction()
	var wall_direction = WALL_COLLISIONS.get_wall_direction()
	
	if (WALL_COLLISIONS.is_on_wall() and JUMP_BUFFER.has_jumped) and \
			(wall_direction != 0 and input_direction != 0):
		PLAYER.velocity.x = PLAYER.WALL_JUMP_LEAP * -wall_direction
		PLAYER.velocity.y = 0
		transition.emit("PlayerJumpState")
	
	# Coyote Time
	elif coyote_jump and Input.is_action_just_pressed("jump"):
		print("coyote time")
		transition.emit("PlayerJumpState")
	
	elif PLAYER.is_on_floor():
		transition.emit("PlayerIdleState")
	
	#elif PLAYER.is_on_wall() and PLAYER.get_wall_direction() == PLAYER.get_input_direction():
		#transition.emit("PlayerWallSlideState")

func _on_timeout() -> void:
	print("end coyote time")
	coyote_jump = false
