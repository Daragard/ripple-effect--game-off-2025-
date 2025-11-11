class_name PlayerFallState

extends PlayerMovementState

@export var WALL_COLLISIONS : WallCollisions
@export var JUMP_BUFFER : JumpBuffer
@onready var TIMER : Timer = $"."
@onready var step_audio_player: AudioStreamPlayer = $"../../StepAudioPlayer"
@onready var kick_audio_player: AudioStreamPlayer = $"../../KickAudioPlayer"
var coyote_jump = false

func enter(previous_state_name : String) -> void:
	ANIMATED_SPRITE.play("fall")

func coyote_start():
	TIMER.start()
	coyote_jump = true

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(delta)
	PLAYER.update_velocity()
	flip_sprite()
	var input_direction = PLAYER.get_input_direction()
	var wall_direction = WALL_COLLISIONS.get_wall_direction()
	
	# Wall Jump
	if (WALL_COLLISIONS.is_on_wall() and JUMP_BUFFER.has_jumped) and \
			(wall_direction != 0 and input_direction != 0):
		PLAYER.velocity.x = PLAYER.WALL_JUMP_LEAP * -wall_direction
		PLAYER.velocity.y = 0
		Input.start_joy_vibration(0, 0.05, 0, .05)
		kick_audio_player.pitch_scale = randf_range(0.6, 0.8)
		kick_audio_player.play()
		transition.emit("PlayerJumpState")
	
	# Coyote Time
	elif coyote_jump and Input.is_action_just_pressed("jump"):
		print("coyote time")
		transition.emit("PlayerJumpState")
	
	elif PLAYER.is_on_floor():
		Input.start_joy_vibration(0, 0.05, 0, .05)
		step_audio_player.pitch_scale = randf_range(0.7, 1.3)
		step_audio_player.play()
		transition.emit("PlayerIdleState")

func flip_sprite():
	var input_direction = PLAYER.get_input_direction()
	if input_direction < 0:
		ANIMATED_SPRITE.flip_h = true
	elif input_direction > 0:
		ANIMATED_SPRITE.flip_h = false

func _on_timeout() -> void:
	coyote_jump = false
