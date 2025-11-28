## LevelSelectManager.gd
extends Node3D

## The main menu scene path to load when the back button is pressed.
@export var main_menu_scene_path: String = "res://Controllers/Managers/Main Menu/main_menu.tscn"

@export var level_containers : Array[Node]

func _ready() -> void:
	# --- NEW: Get Saved Progress Data ---
	# NOTE: Assuming SaveData is a globally accessible class/singleton with these properties
	# furthest_world is typically 0-based index
	# furthest_level is typically 1-based index (e.g., Level 3)
	var furthest_world: int = SaveManager.data.furthest_world
	var furthest_level: int = SaveManager.data.furthest_level + 1
	
	print("Furthest Progress: W%d L%d" % [furthest_world, furthest_level])
	# ------------------------------------
	
	var container_count : int = 0
	for container in level_containers:
		# 'container_count' represents the World Index (0, 1, 2, ...)
		var current_world_index = container_count
		
		for child in container.get_children():
			if child is Button:
				var current_level_number = int(child.text) # This is the 1-based level number (1, 2, 3, ...)
				
				# 1. Determine if the button should be disabled
				var should_be_disabled: bool = false
				
				if current_world_index > furthest_world:
					# Case A: Current world is strictly ahead of the furthest reached world.
					should_be_disabled = true
				elif current_world_index == furthest_world:
					# Case B: Current world is the furthest reached world.
					if current_level_number > furthest_level:
						# Disable any level in this world that is ahead of the furthest level.
						should_be_disabled = true
				# Case C: current_world_index < furthest_world: Button is in a previous world, so it's always enabled.
				
				
				# 2. Disable the button if needed and update its visual style
				if should_be_disabled:
					child.disabled = true
					# Optional: Change the visual appearance to look "locked"
					# You might want to use a custom theme or texture here.
					# Example: child.modulate = Color(0.5, 0.5, 0.5) # Gray it out
					print("Disabled W%d L%d" % [current_world_index, current_level_number])
				else:
					# 3. If the level is unlocked, connect its signal
					var load_level_function = Callable(self, "load_level").bind(current_world_index, current_level_number)
					child.connect("button_up", load_level_function)

		container_count += 1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		go_back_to_main_menu()

## Public method called by a level selection button.
func load_level(world: int, level: int) -> void:
	print("Loading World %s, Level %s..." % [world, level])

	# 1. Set the internal level data in the LevelLoader
	# This assumes the function signature matches your description: set_internal_world_level(world:int, level:int)
	SceneManager.set_internal_world_level(world, level)

	# 2. Call the function to switch the scene and start the level
	SceneManager.restart_level()


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
