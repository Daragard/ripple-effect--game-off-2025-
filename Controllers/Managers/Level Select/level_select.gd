## LevelSelectManager.gd
extends Node3D

## The main menu scene path to load when the back button is pressed.
## Set this in the Inspector to the file path (e.g., "res://scenes/main_menu.tscn").
@export var main_menu_scene_path: String = "res://Controllers/Managers/Main Menu/main_menu.tscn"

@export var level_containers : Array[Node]

func _ready() -> void:
	var container_count : int = 0
	for container in level_containers:
		for child in container.get_children():
			if child is Button:
				print("adding to " + child.name)
				var load_level_function = Callable(self, "load_level").bind(container_count, int(child.text))
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
