class_name JumpBuffer
extends Timer

var has_jumped : bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		has_jumped = true
		start()

func _on_timeout() -> void:
	has_jumped = false
