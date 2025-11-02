class_name State

extends Node

signal transition(new_state_name: StringName)
signal on_enter()

func enter(previous_state_name : String) -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
