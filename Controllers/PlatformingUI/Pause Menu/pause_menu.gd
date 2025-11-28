extends Panel

@export var main_menu_scene_path: String = "res://Controllers/Managers/Main Menu/main_menu.tscn"
@onready var pause_title : Label = $Panel/VBoxContainer/Label
@onready var resume_button : Button = $Panel/VBoxContainer/Resume

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = true
		get_tree().paused = true
		resume_button.grab_focus()

func resume():
	print("resume")
	if get_tree().paused:
		get_tree().paused = false
		visible = false
		release_focus()

func restart():
	if get_tree().paused:
		get_tree().paused = false
		visible = false
		SceneManager.restart_level()

func load_previous_level():
	if get_tree().paused:
		get_tree().paused = false
		visible = false
		SceneManager.previous_level()

## Public method called when the Back button is pressed.
func go_back_to_main_menu() -> void:
	if get_tree().paused:
		get_tree().paused = false
		visible = false
		# Check if the path is empty
		if main_menu_scene_path.is_empty():
			printerr("Main Menu Scene Path is not set in the inspector. Cannot go back.")
			return
			
		print("Returning to Main Menu...")
		
		# Change the current scene to the scene at the given file path
		# NOTE: This uses change_scene_to_file(path: String)
		get_tree().change_scene_to_file(main_menu_scene_path)
