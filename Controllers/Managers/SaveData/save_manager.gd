# Filename: settings_manager.gd
# Set this script as your global Autoload (Singleton) in Project Settings.
class_name SettingsManager
extends Node

# --- MANAGER LOGIC ---

# This is the instance of the saved data that the whole game will use.
# You access all settings through this 'data' property (e.g., SettingsManager.data.master_volume).
var data: SettingsData

# Called when the Autoload is initialized.
func _init():
	# Load the settings immediately when the game starts.
	data = load_or_create()

## Saves the current state of the 'data' resource instance to the disk.
# This function is non-static, called on the global SettingsManager instance.
func save_to_file() -> void:
	# Use the static path defined in the resource data class.
	var error = ResourceSaver.save(data, SettingsData.SAVE_PATH)
	
	if error == OK:
		print("Settings data successfully saved.")
	else:
		# Checking the error code helps with debugging (e.g., permission issues).
		print("ERROR: Failed to save settings (Code: ", error, ")")

## Loads settings from the file, or creates defaults if the file is missing.
# This function is non-static, called on the global SettingsManager instance.
func load_or_create() -> SettingsData:
	var save_path = SettingsData.SAVE_PATH
	
	if FileAccess.file_exists(save_path):
		# The file exists, so we load the resource
		var loaded_resource = ResourceLoader.load(save_path)
		
		# Safety check: ensures the file is the correct resource type
		if loaded_resource is SettingsData:
			print("Settings data loaded successfully.")
			return loaded_resource
		else:
			print("ERROR: Loaded file is not a valid Settings resource. Using defaults.")
			return SettingsData.create_default()
	else:
		# File doesn't exist, create a new default instance
		print("Settings file not found. Creating default settings data.")
		return SettingsData.create_default()

func save_exists() -> bool:
	return FileAccess.file_exists(SettingsData.SAVE_PATH)

## Deletes the save file, resets the 'data' instance to defaults, 
## and restores the volume settings from before the reset.
func delete_save_data() -> void:
	# 1. Temporarily store current volume settings
	var temp_master_volume: float = data.master_volume
	var temp_music_volume: float = data.music_volume
	var temp_sfx_volume: float = data.sfx_volume
	
	var save_path = SettingsData.SAVE_PATH
	
	if FileAccess.file_exists(save_path):
		# 2. Delete the old file
		var error: int = DirAccess.remove_absolute(save_path)
		
		if error == OK:
			print("Old settings file successfully deleted.")
		else:
			# Handle deletion failure, though it may not stop the process
			print("WARNING: Could not delete settings file (Code: ", error, ").")
	else:
		print("No settings file found to delete.")

	# 3. Create a new default data instance
	var new_default_data: SettingsData = SettingsData.create_default()
	
	# Update the global instance to the new default data
	data = new_default_data
	
	# 4. Restore the volume settings to the new data instance
	data.master_volume = temp_master_volume
	data.music_volume = temp_music_volume
	data.sfx_volume = temp_sfx_volume
	
	print("Settings data reset to defaults, but volume values restored.")
	
	# 5. Save the new default data (with original volume) to the file
	save_to_file()

func save_progress():
	data.current_world = SceneManager.current_world_index
	data.current_level = SceneManager.current_level_index
	
	if data.current_world > data.furthest_world:
		data.furthest_world = data.current_world
	
	if data.current_level > data.furthest_level:
		data.furthest_level = data.current_level
	
	print("saving level " + str(SceneManager.current_world_index) + "-" + str(SceneManager.current_level_index) + " to file")
	
	save_to_file()

## Updates the best completion time for a specific level.
## It handles resizing the 2D array automatically to prevent "Index out of bounds" errors.
func save_time_for_level(current_world_index: int, current_level_index: int, new_time: float) -> void:
	
	# Reference to the data for cleaner code
	var times: Array[Array] = data.best_completion_times
	
	# --- 1. Ensure the World Index Exists (Outer Array) ---
	# If the current index is outside the bounds of the outer array, resize it.
	if current_world_index >= times.size():
		# Append enough empty Arrays (representing new Worlds) up to the required index
		times.resize(current_world_index + 1)
	
	# --- 2. Ensure the Level Array Exists and is Initialized (Inner Array) ---
	var world_levels: Array = times[current_world_index]
	
	# Check if the inner array (the World's levels) is null/empty and initialize it.
	if world_levels == null:
		world_levels = []
		times[current_world_index] = world_levels
	
	# --- 3. Ensure the Level Index Exists (Inner Array) ---
	# If the current level index is outside the bounds of the inner array, resize it.
	if current_level_index >= world_levels.size():
		var old_size = world_levels.size()
		# Resize the inner array up to the required index
		world_levels.resize(current_level_index + 1)
		
		# Fill all newly created slots with a default "no time set" value (-1.0)
		for i in range(old_size, world_levels.size()):
			# We use -1.0 to signify that no time has been set yet.
			world_levels[i] = -1.0 

	# --- 4. Comparison and Update ---
	var current_best_time: float = world_levels[current_level_index]

	# Check if this is the first time saved OR if the new time is faster
	if current_best_time == -1.0 or new_time < current_best_time:
		world_levels[current_level_index] = new_time
		print("New best time recorded for W%d-L%d: %f" % [current_world_index, current_level_index, new_time])
		
		# --- 5. Final Save ---
		save_to_file()
	else:
		print("Time %f was not better than current best %f for W%d-L%d." % [new_time, current_best_time, current_world_index, current_level_index])

## Retrieves the best recorded completion time for a specific world and level.
## Returns -1.0 if no time has been recorded (i.e., index doesn't exist or value is -1.0).
func get_time_for_level(world_index: int, level_index: int) -> float:
	
	var times: Array[Array] = data.best_completion_times
	
	# --- 1. Check World Index ---
	# If the requested world index is outside the bounds, the time doesn't exist.
	if world_index < 0 or world_index >= times.size():
		return -1.0 # World does not exist in the saved data

	var world_levels: Array = times[world_index]
	
	# Check for null inner array (safety check)
	if world_levels == null:
		return -1.0 # Inner array is null

	# --- 2. Check Level Index ---
	# If the requested level index is outside the bounds, the time doesn't exist.
	if level_index < 0 or level_index >= world_levels.size():
		return -1.0 # Level does not exist in the saved data

	# --- 3. Retrieve and Interpret Time ---
	var best_time: float = world_levels[level_index]

	# If the value is the sentinel value (-1.0), or any unexpected negative value, return -1.0.
	if best_time <= 0.0:
		return -1.0
	
	# If the value is a positive float, return the actual best time
	return best_time

# --- Quick Usage Guide ---
# 1. Set this script as an Autoload in Project Settings.
# 2. To change a setting anywhere: SettingsManager.data.master_volume = 0.5
# 3. To save the changes: SettingsManager.save_to_file()
# 4. To delete all progress/settings (keeping volume): SettingsManager.delete_save_data()
