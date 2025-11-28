extends Node

# --- Level Data & State ---

# The 2D array to store the scene paths.
# levels[world_index][level_index] = "res://levels/1-1.tscn"
var levels: Array = [] 

# The folder where your level scenes are stored. Make sure this path is correct!
const LEVELS_FOLDER: String = "res://Levels/" 

const LEVEL_OVERVIEW_PATH: String = "res://Controllers/Managers/LevelOverview/level_overview.tscn"

# Current position in the levels array (0-based indices)
var current_world_index: int = 0
var current_level_index: int = 0
var current_completion_time: float = 0

# --- Debounce/Lock Variable ---
# New variable to prevent multiple scene changes in one frame or during a brief transition.
var is_changing_scene: bool = false


# --- Initialization ---

var is_debug: bool = false

func _ready() -> void:
	# 1. Load all levels into the array structure
	load_levels_from_folder()
	
	# 2. Set an initial position (e.g., start at World 1, Level 1)
	# You might want to save and load this data in a real game.
	current_world_index = 0
	current_level_index = 0
	
	# Optional: Load the very first level of the game on startup
	# if levels.size() > 0 and levels[0].size() > 0:
	#    restart_level()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_next_level") and is_debug:
		print("DEBUG: Next Level")
		next_level()
	elif event.is_action_pressed("debug_prev_level") and is_debug:
		print("DEBUG: Previous Level")
		previous_level()
	elif event.is_action_pressed("debug_next_world") and is_debug:
		print("DEBUG: Next World")
		next_world()
	elif event.is_action_pressed("debug_prev_world") and is_debug:
		print("DEBUG: Previous World")
		previous_world()


# --- Core Level Scanning Function ---

## Scans the specified folder and populates the levels array.
func load_levels_from_folder():
	var dir = DirAccess.open(LEVELS_FOLDER)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var base_name = file_name.get_basename()
				var parts = base_name.split("-")
				
				# 1. Check if we have two parts separated by a hyphen
				if parts.size() == 2:
					var world_num = parts[0].to_int()
					var level_num = parts[1].to_int()
					
					# 2. Add validation: Numbers must be greater than zero for 1-based indexing
					if world_num >= 0 and level_num > 0:
						# Convert to 0-based index
						var world_index = world_num
						var level_index = level_num - 1
						var full_path = LEVELS_FOLDER + file_name
						
						# Ensure the outer levels array is big enough
						if world_index >= levels.size():
							levels.resize(world_index + 1)
						
						# Ensure the inner world array is initialized
						# If the slot is null, create an empty array there.
						if levels[world_index] == null:
							levels[world_index] = []
						
						# Resize the inner array to accommodate the new level
						# We access it directly using levels[world_index]
						if level_index >= levels[world_index].size():
							levels[world_index].resize(level_index + 1)
							
						# Add the scene path
						levels[world_index][level_index] = full_path # <-- SIMPLIFIED ACCESS
					else:
						# Print an error if a file matches the pattern but has a non-positive number (e.g., "0-1.tscn" or "-1-1.tscn")
						print("WARNING: Level file name invalid (must be > 0): " + file_name)
				else:
					# Print a warning if a .tscn file doesn't follow the X-Y naming
					print("WARNING: Level file skipped (does not match X-Y.tscn format): " + file_name)
					
			file_name = dir.get_next()
			
		dir.list_dir_end()
		print("Level structure loaded successfully. Worlds found: " + str(levels.size()))
	else:
		print("ERROR: Could not open the directory: " + LEVELS_FOLDER + ". Check your file structure.")


# --- Internal Index Manipulation Functions ---

## Advances the internal level count.
## - Goes to the first level of the next world if at the end of the current world.
## - If on the last level of the last world, stays on the current level.
func set_internal_next_level():
	var next_level_index = current_level_index + 1
	var current_world_levels: Array = []
	
	# 1. Basic safety check for the current world
	if current_world_index < levels.size() and levels[current_world_index] != null:
		current_world_levels = levels[current_world_index]
	else:
		# Should not happen if game is running correctly, but good for safety
		print("ERROR: Current world index is invalid.")
		return

	# 2. Check if the next level is in the current world
	if next_level_index < current_world_levels.size():
		# The next level exists in the current world.
		current_level_index = next_level_index
		print("Internal state set to next level: W%d L%d" % [current_world_index, current_level_index])
	else:
		# Last level of the current world. Try to move to the next world.
		var next_world_index = current_world_index + 1
		
		# 3. Check if the next world exists and has levels
		if next_world_index < levels.size() and levels[next_world_index] != null and levels[next_world_index].size() > 0:
			# Next world exists: Go to the first level (index 0)
			current_world_index = next_world_index
			current_level_index = 0
			print("Internal state set to next world's first level: W%d L%d" % [current_world_index, current_level_index])
		else:
			# Last level of the last world: Stay on the current level.
			print("Internal state remains on W%d L%d (Last level of all worlds)." % [current_world_index, current_level_index])


## Retreats the internal level count (inverse of set_internal_next_level).
## - Goes to the last level of the previous world if at the first level of the current world.
## - If on the first level of the first world, stays on the current level.
func set_internal_previous_level():
	var previous_level_index = current_level_index - 1
	
	# 1. Check if the previous level is in the current world
	if previous_level_index >= 0:
		# The previous level exists in the current world.
		current_level_index = previous_level_index
		print("Internal state set to previous level: W%d L%d" % [current_world_index, current_level_index])
	else:
		# First level of the current world. Try to move to the previous world.
		var previous_world_index = current_world_index - 1
		
		# 2. Check if the previous world exists
		if previous_world_index >= 0:
			# Safety check: ensure the previous world array exists and has levels
			if levels[previous_world_index] != null and levels[previous_world_index].size() > 0:
				# Previous world exists: Go to the LAST level of that world
				current_world_index = previous_world_index
				# Set level index to the LAST level of the new current world
				current_level_index = levels[current_world_index].size() - 1 
				print("Internal state set to previous world's last level: W%d L%d" % [current_world_index, current_level_index])
			else:
				# Should not happen in a valid setup
				print("ERROR: Previous World %d exists but contains no levels. State remains unchanged." % [previous_world_index])
		else:
			# First level of the first world: Stay on the current level.
			print("Internal state remains on W%d L%d (First level of first world)." % [current_world_index, current_level_index])


func set_internal_world_level(world : int, level : int):
	print("setting internal world:level " + str(world) + ":" + str(level))
	current_world_index = world
	current_level_index = level - 1 # To make it start at zero


# --- Level Loading Functions ---

func load_level_from_save():
	current_world_index = SaveManager.data.current_world
	current_level_index = SaveManager.data.current_level
	print("loading level " + str(current_world_index) + "-" + str(current_level_index) + " from save")
	restart_level()

## Helper function to perform the scene change.
func _change_scene(path: String):
	# The lock is set here, BEFORE the scene change is initiated.
	is_changing_scene = true 
	
	if FileAccess.file_exists(path):
		# Godot will change the scene.
		get_tree().change_scene_to_file.call_deferred(path)
		
		# --- FIX: Deferred Lock Release ---
		# call_deferred ensures the lock is released after the current processing is done,
		# meaning it will happen *after* the scene change has been initiated and the new
		# scene tree is starting to process.
		call_deferred("_release_scene_lock")
		# -----------------------------------
	else:
		print("ERROR: Scene file not found at path: " + path)
		# If the scene change fails, release the lock immediately so the player can try again.
		is_changing_scene = false 


## Releases the scene lock variable. Called via call_deferred after initiating a scene change.
func _release_scene_lock():
	is_changing_scene = false


## Loads the current level using the stored indices. (Renamed from load_current_level)
func restart_level():
	# Check the lock first! If we are already changing scenes, do nothing.
	if is_changing_scene:
		return 

	# Check if the current indices are valid
	if current_world_index < levels.size() and \
	   current_level_index < levels[current_world_index].size():
		
		var level_path = levels[current_world_index][current_level_index]
		
		if level_path: # Ensure the slot isn't null (due to sparse indexing)
			SaveManager.save_progress()
			_change_scene(level_path)
		else:
			print("Error: Level path is null at W" + str(current_world_index) + " L" + str(current_level_index) + ". Check file naming.")
	else:
		print("Error: Current level index out of bounds.")

func load_level_overview(level_completion_time : float):
	current_completion_time = level_completion_time
	SaveManager.save_progress()
	_change_scene(LEVEL_OVERVIEW_PATH)

## Attempts to load the next level in the current world. (Renamed from load_next_level)
func next_level():
	# Check the lock first! If we are already changing scenes, do nothing.
	if is_changing_scene:
		return
		
	var next_level_index = current_level_index + 1
	
	# Safety check: make sure current_world_index is valid before accessing levels[current_world_index]
	if current_world_index >= levels.size() or levels[current_world_index] == null:
		print("ERROR: World index is invalid or world array is null. Cannot proceed.")
		return
		
	var current_world_levels = levels[current_world_index]
	
	# Check if the next level index is within the bounds of the current world
	if next_level_index < current_world_levels.size() and current_world_levels[next_level_index]:
		# Next level exists: Update index and load
		current_level_index = next_level_index
		restart_level() # Calls the renamed function
	else:
		# Last level of the world completed (since we are on the current world)
		print("WORLD " + str(current_world_index) + " COMPLETED!")
		next_world()

## Attempts to load the previous level in the current world.
func previous_level():
	# Check the lock first! If we are already changing scenes, do nothing.
	if is_changing_scene:
		return

	var previous_level_index = current_level_index - 1
	
	# Check if we are still within the current world (index must be 0 or greater)
	if previous_level_index >= 0:
		# Previous level exists: Update index and load
		current_level_index = previous_level_index
		restart_level() # Calls the function to load the updated level
	else:
		# We are on the very first level of the current world
		print("Cannot go back: Already on Level 1 of World " + str(current_world_index + 1))

## Attempts to load the next world's first level.
func next_world():
	# Check the lock first! If we are already changing scenes, do nothing.
	if is_changing_scene:
		return

	var next_world_index = current_world_index + 1

	# Check if the next world index is within the bounds of the levels array
	if next_world_index < levels.size() and levels[next_world_index] != null and levels[next_world_index].size() > 0:
		# Next world exists: Update indices and load the first level (index 0)
		current_world_index = next_world_index
		current_level_index = 0
		restart_level() # Calls the function to load the updated level (e.g., World 2, Level 1)
	else:
		# We are on the last world or the next world array is empty/null
		print("GAME COMPLETED! No more worlds found after World " + str(current_world_index + 1))


## Attempts to load the previous world's last level.
func previous_world():
	# Check the lock first! If we are already changing scenes, do nothing.
	if is_changing_scene:
		return

	var previous_world_index = current_world_index - 1
	
	# Check if we are past the first world (index 0)
	if previous_world_index >= 0:
		# Safety check: ensure the previous world array exists and has levels
		if levels[previous_world_index] != null and levels[previous_world_index].size() > 0:
			# Previous world exists: Update world index and set level index to the LAST level
			current_world_index = previous_world_index
			current_level_index = levels[current_world_index].size() - 1 # Set to the last level index
			
			print("Moving to World " + str(current_world_index + 1) + ", Last Level.")
			restart_level() # Calls the function to load the updated level
		else:
			print("ERROR: Previous World " + str(previous_world_index + 1) + " exists but contains no levels.")
	else:
		# We are on the very first world
		print("Cannot go back: Already on World 1")
