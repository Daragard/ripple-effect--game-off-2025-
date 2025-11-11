class_name SceneList
extends Resource

@export var scenes : Array[PackedScene]

func get_next_scene(current_scene : int) -> PackedScene:
	if len(scenes) <= current_scene + 1:
		return null
	else:
		return scenes[current_scene + 1]
