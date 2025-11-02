class_name WallSlide

extends PlayerMovementState

@export var JUMP_BUFFER : JumpBuffer
@onready var TIMER : Timer = $"."

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var holding_wall : bool = true
var can_hold_wall : bool = true

func enter(previous_state_name : String) -> void:
	ANIMATED_SPRITE.play("wall_slide")
	TIMER.stop()
	TIMER.start()

func update(delta: float) -> void:
	var wall_direction : int = PLAYER.get_wall_direction()
	var player_input_direction : int = PLAYER.get_input_direction()
	
	if wall_direction == -1 and player_input_direction < 0: # left
		holding_wall = true
	elif wall_direction == 1 and player_input_direction > 0: # right
		holding_wall = true
	elif holding_wall:
		holding_wall = false
	
	if Input.is_action_just_pressed("jump") and wall_direction != 0 and player_input_direction != 0:
		if wall_direction == player_input_direction:
			PLAYER.velocity.x = PLAYER.WALL_JUMP_LEAP * -wall_direction
		transition.emit("PlayerJumpState")
	
	elif PLAYER.is_on_floor():
		transition.emit("PlayerIdleState")
	
	elif !holding_wall:
		transition.emit("PlayerFallState")

func exit() -> void:
	PLAYER.velocity.y = 0
	holding_wall = false

func reduce_gravity():
	# This could be problematic for moving platforms
	if PLAYER.velocity.y > (gravity * 0.01):
		PLAYER.velocity.y = gravity * 0.01

func _on_timeout() -> void:
	if !PLAYER.is_on_floor():
		transition.emit("PlayerFallState")
		can_hold_wall = false
