extends Area2D

@export var NON_LEVEL_SCENE : PackedScene
@export var LOAD_NEXT_WORLD : bool = false
@onready var ANIMATED_SPRITE : AnimatedSprite2D = $AnimatedSprite2D
@onready var sound_effect_timer: Timer = $SoundEffectTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var door_open : bool = false
var player : Player

func _input(event: InputEvent) -> void:
	if event.get_action_strength("up") > 0.75 and door_open:
		if player.is_on_floor():
			if NON_LEVEL_SCENE:
				get_tree().change_scene_to_file.call_deferred(NON_LEVEL_SCENE.resource_path)
				return

			if LOAD_NEXT_WORLD:
				SceneManager.next_world()
			else:
				SceneManager.next_level()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		ANIMATED_SPRITE.play("open")
		door_open = true
		if sound_effect_timer.is_stopped():
			sound_effect_timer.start()
			audio_stream_player.play()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		ANIMATED_SPRITE.play("close")
		door_open = false
