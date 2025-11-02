class_name PlayerMovementState

extends State

var PLAYER : Player
var STATE_MACHINE : StateMachine
@export var ANIMATED_SPRITE: AnimatedSprite2D

func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	STATE_MACHINE = PLAYER.STATE_MACHINE
	ANIMATED_SPRITE = PLAYER.ANIMATED_SPRITE
