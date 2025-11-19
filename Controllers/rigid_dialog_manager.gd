extends Control

# --- Exported Variables ---

# 1. NEW: Single, large multiline text input box for all dialogue.
# Use the 'line_separator' (default is ---) to split lines.
@export_multiline var raw_dialogue_text: String = "Welcome to the village.\n---\nI have a task for you.\n---\nGood luck on your journey!"
# 2. NEW: The text string used to separate individual dialogue blocks.
@export var line_separator: String = "---" 

@export var typing_speed: float = 0.05 # Delay between characters in seconds

@export var next_scene: PackedScene

# --- Node References ---
@onready var dialogue_label: RichTextLabel = $MarginContainer/Panel/MarginContainer2/RichTextLabel
@onready var typing_timer: Timer = $TypingTimer

# --- Internal State ---
# This will now hold the parsed lines after splitting the raw_dialogue_text.
var texts: PackedStringArray = []
var current_text_index: int = 0
var current_line: String = ""
var is_typing: bool = false
var visible_characters: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Parse the raw multiline text into a PackedStringArray
	var split_result: PackedStringArray = raw_dialogue_text.split(line_separator + "\n", false)
	
	# FIX: Using a loop instead of the .filter() method to avoid type error 
	# when assigning the result back to the PackedStringArray variable.
	var filtered_texts: PackedStringArray = []
	for line in split_result:
		# Check if the line is not empty after stripping whitespace/edges
		if not line.strip_edges().is_empty():
			filtered_texts.append(line)
			
	texts = filtered_texts
	
	# Set up the timer
	typing_timer.wait_time = typing_speed
	typing_timer.one_shot = false
	typing_timer.timeout.connect(_on_typing_timer_timeout)

	# Start the dialogue automatically
	start_dialogue()

# --- Dialogue Core Functions ---

func start_dialogue() -> void:
	# Ensure the control is visible and start with the first line
	show()
	current_text_index = 0
	display_current_line()

func display_current_line() -> void:
	if current_text_index < texts.size():
		# Get the new line and reset typing state
		current_line = texts[current_text_index]
		visible_characters = 0
		dialogue_label.visible_characters = 0
		dialogue_label.text = current_line
		
		# Start the typing animation
		is_typing = true
		typing_timer.start()
	else:
		# Dialogue has finished
		end_dialogue()

func end_dialogue() -> void:
	# Handle what happens when dialogue is over (e.g., hide the box)
	print("--- Dialogue Finished ---")
	if next_scene:
		get_tree().change_scene_to_file.call_deferred(next_scene.resource_path)
	else:
		push_warning("WARNING: There was no scene to load after completing the dialog!")

# --- Typing Animation Logic ---

func _on_typing_timer_timeout() -> void:
	if visible_characters < current_line.length():
		# Show one more character
		visible_characters += 1
		dialogue_label.visible_characters = visible_characters
	else:
		# The line is fully typed, stop the animation
		typing_timer.stop()
		is_typing = false
		dialogue_label.visible_characters = -1 # Ensure all characters are visible

# --- Input Handling ---

# Function to be called when the player presses the "advance text" button
func advance_text() -> void:
	if is_typing:
		# Requirement 4: Player hits advance while text is typing (Skips typing animation)
		typing_timer.stop()
		dialogue_label.visible_characters = -1 # Instantly show all text
		is_typing = false
	else:
		# Requirement 5: Text is already fully displayed (Advances to next text block)
		current_text_index += 1
		display_current_line()

# --- Example Input Integration (Assumes "ui_accept" is mapped to your controller button) ---

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advance_text()
		get_viewport().set_input_as_handled() # Consume the input event
