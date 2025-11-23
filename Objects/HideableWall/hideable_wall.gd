extends Node2D

@export var hide_on_start : bool = true
@onready var sprites : Node2D = $Sprites
@onready var collisions : CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	if hide_on_start:
		hide_wall()

func toggle_wall(_body: Node2D):
	if sprites.visible == true:
		hide_wall()
	else:
		show_wall()

func show_wall(_body: Node2D = null):
	sprites.visible = true
	
	collisions.call_deferred("set", "disabled", false)

func hide_wall(_body: Node2D = null):
	sprites.visible = false
	
	collisions.call_deferred("set", "disabled", true)
