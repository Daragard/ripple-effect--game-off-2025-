extends Node3D

# --- [ Section 1: Scene & Save File Variables ] ---

## The file path to the main game scene to load upon starting a new game or continuing.
@export var main_game_scene_path: String

## The file path to the Level Select menu scene.
@export var level_select_scene_path: String

## The file path to the Settings menu scene.
@export var settings_scene_path: String

## The file path for the player's progress save file.
const SAVE_FILE_PATH = "user://game_save.sav"

# --- [ Section 2: UI Connections ] ---

# The following functions should be connected to the 'pressed()' signal 
# of their respective buttons in the editor.

## Function connected to the START button.
func _on_start_button_pressed():
	print("START button pressed.")
	_load_game_or_start_new()

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


# --- [ Section 3: Core Logic (Start/Load) ] ---

## Loads the game based on the last saved level, or starts the main game scene.
func _load_game_or_start_new():
	var current_level_scene_path: String = ""
	
	# 1. Attempt to load the save file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	
	if file:
		# Save file exists, try to read the level path
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if data is Dictionary and data.has("current_level_path"):
			current_level_scene_path = data["current_level_path"]
			print("Loaded save file. Continuing on level: " + str(current_level_scene_path))
		else:
			push_warning("Save file data is corrupt or missing 'current_level_path'. Starting new game.")
			# If save is corrupt, fall through to loading the default scene
	else:
		# 2. If no save file exists, start the game from the default scene
		print("No save file found. Starting new game.")
	
	# 3. Determine which scene to load (Saved level path or default main game scene)
	if !current_level_scene_path.is_empty():
		# Load the scene specified in the save file
		# Note: We don't need to check for PackedScene here, 
		# we just pass the file path directly to the change scene function.
		_change_scene_to_file(current_level_scene_path)
		return

	# 4. Fallback: Load the default main game scene
	if not main_game_scene_path.is_empty():
		_change_scene_to_file(main_game_scene_path)
	else:
		push_error("Main Game Scene Path is not set in the inspector! Cannot start game.")


# --- [ Section 4: Scene Management Helper ] ---

## Helper function to switch scenes safely using a file path.
func _change_scene_to_file(scene_path: String):
	# Using change_scene_to_file() is the robust way to switch scenes using a path
	var error = get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		push_error("Failed to load scene at path: %s. Error code: %s" % [scene_path, error])


# --- [ Optional: Example Save Function ] ---
# You would call this from your game level script whenever the game saves.

static func save_game_progress(level_path: String):
	var data = {
		"current_level_path": level_path,
		# You can add more data here like "player_health": 100, "inventory": []
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		print("Game progress saved. Current level path: " + str(level_path))
	else:
		push_error("Failed to open file for saving: " + str(SAVE_FILE_PATH))
