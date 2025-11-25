@tool
extends Node3D

# --- [ Section 1: Mesh and Light Swap Variables ] ---

## The Node3D containing the green Mesh.
@export var green_mesh_node: Node3D

## The Node3D containing the orange Mesh.
@export var orange_mesh_node: Node3D

## The Light3D node to control.
@export var scene_light: Light3D

## The color to use when the green mesh is visible. (Fluorescent Green)
@export var green_light_color: Color = Color(0.251, 1.0, 0.616, 1.0)

## The color to use when the orange mesh is visible.
@export var orange_light_color: Color = Color.ORANGE


# --- [ Section 2: Mouse Look Rotation Variables ] ---

# The speed at which the object will rotate (a higher value means faster tracking)
@export var rotation_speed : float = 8.0

# The maximum angle (in degrees) the object is allowed to rotate on the Y and X axes.
@export var max_rotation_degrees : float = 10.0


# --- [ Internal Variables ] ---

var is_orange_active: bool = false # State for the mesh/light swap

var max_rotation_rad : float 	  # Pre-calculated max rotation in radians
var viewport_size : Vector2 	  # The size of the viewport (screen resolution)
var _initial_rotation : Vector3   # Stores the object's rotation set in the editor


func _ready():
	# --- Setup for Mesh/Light Swap ---
	# We start in the "green" state.
	_set_state_to_green()
	
	# --- Setup for Mouse Look ---
	# Store the rotation set in the editor right when the game starts.
	_initial_rotation = rotation
	
	# Pre-calculate the maximum rotation in radians
	max_rotation_rad = deg_to_rad(max_rotation_degrees)
	
	# Get the current viewport size
	viewport_size = get_viewport().get_visible_rect().size


func _process(delta: float):
	# --- Input Handling for Mesh/Light Swap ---
	
	# Check for "jump" or either mouse button press
	if Input.is_action_pressed("ui_accept") or \
			Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or \
			Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_set_state_to_orange()
	else:
		_set_state_to_green()

	# --- Mouse Look Rotation Logic ---
	
	# 1. Calculate normalized mouse offset from screen center (-1.0 to 1.0)
	var mouse_pos_screen : Vector2 = get_viewport().get_mouse_position()
	var screen_center : Vector2 = viewport_size / 2.0
	var offset_normalized : Vector2 = (mouse_pos_screen - screen_center) / screen_center

	# 2. Calculate the new relative rotation (offset)
	# Horizontal (X offset) controls Y-axis rotation (Yaw)
	var target_y_offset : float = clamp(offset_normalized.x, -1.0, 1.0) * max_rotation_rad
	# Vertical (Y offset) controls X-axis rotation (Pitch). Invert Y for intuitive Up/Down.
	var target_x_offset : float = clamp(-offset_normalized.y, -1.0, 1.0) * max_rotation_rad

	# 3. Calculate the FINAL ABSOLUTE target rotation
	var final_target_y_rot : float = _initial_rotation.y + target_y_offset
	var final_target_x_rot : float = _initial_rotation.x + target_x_offset

	# 4. Smoothly interpolate the current rotation towards the target (Yaw and Pitch)
	rotation.y = lerp_angle(rotation.y, final_target_y_rot, rotation_speed * delta)
	rotation.x = lerp_angle(rotation.x, final_target_x_rot, rotation_speed * delta)


# --- [ Private Helper Functions for Mesh/Light Swap ] ---


# Sets the scene to the "green" state.
func _set_state_to_green():
	if green_mesh_node:
		green_mesh_node.visible = true
	if orange_mesh_node:
		orange_mesh_node.visible = false
	if scene_light:
		scene_light.light_color = green_light_color
	
	is_orange_active = false


# Sets the scene to the "orange" state.
func _set_state_to_orange():
	if green_mesh_node:
		green_mesh_node.visible = false
	if orange_mesh_node:
		orange_mesh_node.visible = true
	if scene_light:
		scene_light.light_color = orange_light_color
		
	is_orange_active = true
