extends Control

@export var main_menu_scene_path: String = "res://Controllers/Managers/Main Menu/main_menu.tscn"

## Public method called when the Back button is pressed.
func go_back_to_main_menu() -> void:
	# Check if the path is empty
	if main_menu_scene_path.is_empty():
		printerr("Main Menu Scene Path is not set in the inspector. Cannot go back.")
		return
		
	print("Returning to Main Menu...")
	
	# Change the current scene to the scene at the given file path
	# NOTE: This uses change_scene_to_file(path: String)
	get_tree().change_scene_to_file(main_menu_scene_path)
