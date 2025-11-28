extends Node3D

# --- [ Section 1: Scene & Save File Variables ] ---

## The file path to the main game scene to load upon starting a new game or continuing.
@export var main_game_scene_path: String = "res://Levels/0-1.tscn"

## The file path to the Level Select menu scene.
@export var level_select_scene_path: String = "res://Controllers/Managers/Level Select/level_select.tscn"

## The file path to the Settings menu scene.
@export var settings_scene_path: String =  "res://Controllers/Managers/Settings/settings.tscn"

# --- [ Section 2: UI Connections ] ---

# The following functions should be connected to the 'pressed()' signal 
# of their respective buttons in the editor.

## Function connected to the START button.
func _on_start_button_pressed():
	print("START button pressed.")
	SceneManager.load_level_from_save()

## Function connected to the LEVEL SELECT button.
func _on_level_select_button_pressed():
	print("LEVEL SELECT button pressed.")
	if not level_select_scene_path.is_empty():
		_change_scene_to_file(level_select_scene_path)
	else:
		push_warning("Level Select Scene Path is not set in the inspector!")

## Function connected to the SETTINGS button.
func _on_settings_button_pressed():
	print("SETTINGS button pressed.")
	if not settings_scene_path.is_empty():
		_change_scene_to_file(settings_scene_path)
	else:
		push_warning("Settings Scene Path is not set in the inspector!")

## Function connected to the QUIT button.
func _on_quit_button_pressed():
	print("QUIT button pressed. Exiting game.")
	get_tree().quit()

# --- [ Section 3: Scene Management Helper ] ---

## Helper function to switch scenes safely using a file path.
func _change_scene_to_file(scene_path: String):
	# Using change_scene_to_file() is the robust way to switch scenes using a path
	var error = get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		push_error("Failed to load scene at path: %s. Error code: %s" % [scene_path, error])
