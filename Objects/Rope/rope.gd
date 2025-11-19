extends Area2D

# --- Exported Variables ---
@export_range(1, 100, 1) var ladder_length : int = 1
@export var ladder_sprite : Texture2D
# New export variables for collision customization
@export var collision_offset_x: float = 0.0 # Horizontal offset from the Area2D's origin
@export var collision_width: float = 0.0    # Width of the collision shape. If 0, uses sprite width.

# --- Constants for Collision/Sprite Logic ---
const SPRITE_HEIGHT: float = 16.0
const OVERLAP: float = 1.0
const EFFECTIVE_HEIGHT: float = SPRITE_HEIGHT - OVERLAP # 15.0

# NOTE: The @onready var collision has been removed since we are creating
# a unique collision shape for every segment now.

func _ready() -> void:
	# 1. Clear any existing dynamically generated nodes (both sprites and old collision shapes)
	for child in get_children():
		if child is Sprite2D or child is CollisionShape2D:
			child.queue_free()
	
	# Determine the width to use for collision box sizing
	var final_collision_width: float = collision_width
	if final_collision_width <= 0.0 and ladder_sprite:
		# If collision_width is not set (0.0), use the sprite's width
		final_collision_width = ladder_sprite.get_width()
	elif final_collision_width <= 0.0:
		# Fallback if no sprite is assigned
		final_collision_width = 16.0 
	
	# 2. Place ALL ladder segments and their individual collision boxes
	for i in range(ladder_length):
		# Calculate the Y-position for the center of the i-th segment.
		# This places the center of the first segment (i=0) at Y=8.0, 
		# and subsequent segments at Y=23.0, 38.0, 53.0, etc.
		var y_position: float = (SPRITE_HEIGHT / 2.0) + (i * EFFECTIVE_HEIGHT)
		
		# --- Create Sprite ---
		var sprite_node : Sprite2D = Sprite2D.new()
		sprite_node.texture = ladder_sprite
		sprite_node.position.y = y_position
		# Center the sprite horizontally based on its width
		if ladder_sprite:
			sprite_node.position.x = ladder_sprite.get_width() / 2.0
		
		add_child(sprite_node)
		
		# --- Create Unique Collision Shape ---
		var collision_shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		
		# RectangleShape2D uses 'extents' (half the size).
		# Extents are now based on the exported collision_width
		rect_shape.extents = Vector2(final_collision_width / 2.0, SPRITE_HEIGHT / 2.0)
		collision_shape.shape = rect_shape
		
		# Position the collision shape:
		# X position = offset + half the collision width
		collision_shape.position.x = collision_offset_x + (final_collision_width / 2.0)
		collision_shape.position.y = y_position
		
		# Add the new, unique collision shape to the Area2D.
		add_child(collision_shape)

	# 3. Optional: Print for debugging
	var total_height = SPRITE_HEIGHT + ((ladder_length - 1) * EFFECTIVE_HEIGHT)
	print("Ladder created with total height: %.1f" % [total_height])
