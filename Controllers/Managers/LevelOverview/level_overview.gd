extends Control

@onready var current_level_label: Label = $Panel/Panel/MarginContainer/VBoxContainer/VBoxContainer/CurrentLevel
@onready var current_time: Label = $Panel/Panel/MarginContainer/VBoxContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/HBoxContainer/CurrentTime
@onready var time_difference_label: Label = $Panel/Panel/MarginContainer/VBoxContainer/VBoxContainer/CenterContainer/VBoxContainer/HBoxContainer/HBoxContainer/TimeDifference
@onready var best_time_label: Label = $Panel/Panel/MarginContainer/VBoxContainer/VBoxContainer/CenterContainer/VBoxContainer/BestTime

@onready var MAIN_MENU : String = "res://Controllers/Managers/Main Menu/main_menu.tscn"
@onready var SETTINGS : String = ""

func _ready() -> void:
	var current_world : int = SceneManager.current_world_index
	var current_level : int = SceneManager.current_level_index
	
	current_level_label.text = str(current_world) + "-" + str(current_level + 1)
	
	var best_completion_time : float = SaveManager.get_time_for_level(current_world, current_level)
	
	current_time.text = elapsed_time_to_string(SceneManager.current_completion_time)
	
	var time_difference : float = 0
	
	if best_completion_time != -1.0:
		time_difference =  SceneManager.current_completion_time - best_completion_time
	
	print("time difference" + str(time_difference))
	
	if time_difference > 0:
		time_difference_label.add_theme_color_override("font_color", Color.RED) 
		time_difference_label.text = "+" + elapsed_time_to_string(time_difference)
	elif time_difference < 0:
		time_difference_label.add_theme_color_override("font_color", Color.GREEN)
		time_difference_label.text = "-" + elapsed_time_to_string(abs(time_difference))
	else:
		time_difference_label.text = ""
	
	if best_completion_time != -1:
		best_time_label.add_theme_color_override("font_color", Color.WHITE)
		if SceneManager.current_completion_time < best_completion_time:
			best_time_label.text = "Best Time: " + elapsed_time_to_string(SceneManager.current_completion_time)
		else:
			best_time_label.text = "Best Time: " + elapsed_time_to_string(best_completion_time)
	else:
		best_time_label.add_theme_color_override("font_color", Color.YELLOW)
		best_time_label.text = "First Clear!"
	
	SaveManager.save_time_for_level(current_world, current_level, SceneManager.current_completion_time)
	set_progress_as_next_level()

func set_progress_as_next_level():
	SceneManager.set_internal_next_level()
	print("saving progress... = " + str(SceneManager.current_world_index) + "-" + str(SceneManager.current_level_index))
	SaveManager.save_progress()
	SceneManager.set_internal_previous_level()

func elapsed_time_to_string(elapsed_time : float) -> String:
	# Total time in milliseconds
	var total_milliseconds: int = int(elapsed_time * 1000)
	
	# Milliseconds (the last three digits)
	# We take the remainder after dividing by 1000
	var milliseconds: int = total_milliseconds % 1000
	
	# Total time in seconds (full seconds passed)
	var total_seconds: int = total_milliseconds / 1000

	var seconds: int = total_seconds % 60

	var minutes: int = total_seconds / 60

	# --- MODIFIED STRING FORMATTING ---
	
	# Keeping the original three digits, but removing padding is often best:
	var ms_string = ""
	if milliseconds > 0:
		# Use "%03d" if you always want 3 digits (e.g., 050). 
		# Use "%d" if you want 1, 2, or 3 digits (e.g., 50).
		ms_string = "." + ("%03d" % milliseconds) 
		
	# 2. Assembling the final string without leading zero padding for minutes and seconds
	
	if minutes > 0:
		# Format: M:SS.mmm or MM:SS.mmm (no padding for M)
		return "%d:%02d%s" % [minutes, seconds, ms_string]
	elif seconds > 0:
		# Format: S.mmm or SS.mmm (no padding for S)
		return "%d%s" % [seconds, ms_string]
	else:
		# Format: .mmm (only milliseconds, like 0.500)
		return "0%s" % [ms_string]


func _on_previous_button_button_up() -> void:
	SceneManager.previous_level()


func _on_restart_button_button_up() -> void:
	SceneManager.restart_level()


func _on_next_button_button_up() -> void:
	SceneManager.next_level()


func _on_home_button_button_up() -> void:
	SceneManager._change_scene(MAIN_MENU)


func _on_settings_button_button_up() -> void:
	pass # Replace with function body.
