class_name SettingsData
extends Resource

# The file path where this specific resource instance will be saved.
const SAVE_PATH = "user://game_settings.tres"

# --- Properties ---
@export var use_timer : bool = true
@export_range(0.0, 1.0) var master_volume : float = 1.0
@export_range(0.0, 1.0) var music_volume : float = 1.0
@export_range(0.0, 1.0) var sfx_volume : float = 1.0

@export var furthest_world : int = 0
@export var furthest_level : int = 0
@export var current_world : int = 0
@export var current_level : int = 0

@export var best_completion_times: Array[Array] = []

# Helper function to create a new default instance
static func create_default() -> SettingsData:
	return SettingsData.new()
