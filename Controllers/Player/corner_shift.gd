extends Node2D

var left_shift : bool = false
var right_shfit : bool = false

func _on_left_corners_body_entered(body: Node2D) -> void:
	right_shift = true


func _on_right_corners_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
