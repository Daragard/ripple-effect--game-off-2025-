extends Area2D

@export_range(1, 100, 1) var ladder_length : int = 1
@export var ladder_sprite : Texture2D
@onready var collision : CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Adds sprites
	for x in range(ladder_length-1):
		var sprite_node : Sprite2D = Sprite2D.new()
		sprite_node.texture = ladder_sprite
		sprite_node.position.y = 23 + (x * 15)
		add_child(sprite_node)
	
	# Fix collisions
	var final_position = 16 + ((ladder_length - 1) * 15)
	collision.position.y = final_position / 2
	collision.shape.size.y = final_position
