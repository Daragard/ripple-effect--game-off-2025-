extends Node2D

@export var hide_on_start : bool = true
@onready var sprites : Array[Sprite2D]
@onready var collisions : CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	add_children_sprites()
	if hide_on_start:
		hide_wall()

func add_children_sprites():
	for child in get_children():
		if child is Sprite2D:
			sprites.append(child)

func toggle_wall(_body: Node2D):
	if sprites[0].visible == true:
		hide_wall()
	else:
		show_wall()

func show_wall(_body: Node2D = null):
	for sprite in sprites:
		sprite.visible = true
	
	collisions.call_deferred("set", "disabled", false)

func hide_wall(_body: Node2D = null):
	for sprite in sprites:
		sprite.visible = false
	
	collisions.call_deferred("set", "disabled", true)
