class_name KillZone
extends Area2D

func _on_player_enter_zone(body: Node2D) -> void:
	print("restart")
	SceneManager.restart_level()
