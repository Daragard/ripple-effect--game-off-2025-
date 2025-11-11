class_name WallCollisions
extends Node2D

@onready var left_collider : Area2D= $LeftCollider
@onready var right_collider : Area2D = $RightCollider

var right_collision : bool
var left_collision : bool

func _physics_process(_delta: float) -> void:
	left_collision = len(left_collider.get_overlapping_bodies()) > 0 or \
			len(left_collider.get_overlapping_areas()) > 0
	right_collision = len(right_collider.get_overlapping_bodies()) > 0 or \
			len(right_collider.get_overlapping_areas()) > 0

func get_wall_direction() -> int:
	if left_collision and not right_collision:
		return -1
	elif right_collision and not left_collision:
		return 1
	else:
		return 0

func is_on_wall() -> bool:
	return left_collision or right_collision
