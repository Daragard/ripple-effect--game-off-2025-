extends Label

# Variable to track the total elapsed time in seconds
var elapsed_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure the label is initialized with a zero time
	text = "00:00:000"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	elapsed_time += delta
	text = elapsed_time_to_string(elapsed_time)

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

	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
