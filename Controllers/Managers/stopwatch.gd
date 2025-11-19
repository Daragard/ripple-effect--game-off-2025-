extends Label

# Tracks the total time the stopwatch has been running (in seconds).
var time_elapsed: float = 0.0

# Controls whether the timer is currently updating.
var is_running: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start the stopwatch automatically as requested.
	is_running = true
	# Set the initial display to "00:00:000"
	_update_display()
	
	# Optional: Increase the label's font size here if needed!
	# self.add_theme_font_size_override("font_size", 48)

# Called every frame. 'delta' is the time elapsed since the previous frame.
func _process(delta: float) -> void:
	if is_running:
		# Add the time passed since the last frame to the total time.
		time_elapsed += delta
		# Update the text displayed on the Label.
		_update_display()

# Function to convert the float time into the required MM:SS:NNN format
func _update_display() -> void:
	# 1. Calculate Minutes (MM)
	var minutes: int = int(time_elapsed / 60.0)
	
	# 2. Calculate Seconds (SS)
	# Use fmod to get the remaining seconds (0.0 to 59.999...)
	var seconds_total: float = fmod(time_elapsed, 60.0)
	var seconds_only: int = int(seconds_total)
	
	# 3. Calculate Milliseconds (NNN)
	# Get the fractional part of the total time (e.g., 0.12345) and scale it to 1000.
	var fractional_seconds: float = fmod(time_elapsed, 1.0)
	var milliseconds: int = int(fractional_seconds * 1000.0)
	
	# Format the string: MM:SS:NNN
	# %02d ensures two digits with a leading zero (e.g., 05)
	# %03d ensures three digits with leading zeros (e.g., 007)
	text = "%02d:%02d:%03d" % [minutes, seconds_only, milliseconds]

# --- Optional Control Functions ---

func start_timer() -> void:
	is_running = true

func stop_timer() -> void:
	is_running = false

func reset_timer() -> void:
	time_elapsed = 0.0
	_update_display()
	is_running = false
