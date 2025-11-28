extends Node3D

@export var MAIN_MENU = "res://Controllers/Managers/Main Menu/main_menu.tscn"

@onready var use_timer: CheckBox = $Control/MarginContainer/MarginContainer/VBoxContainer/UseTimer
@onready var master_volume: HSlider = $Control/MarginContainer/MarginContainer/VBoxContainer/MasterVolume
@onready var music_volume: HSlider = $Control/MarginContainer/MarginContainer/VBoxContainer/MusicVolume
@onready var sfx_volume: HSlider = $Control/MarginContainer/MarginContainer/VBoxContainer/SFXVolume

func _ready() -> void:
	use_timer.button_pressed = SaveManager.data.use_timer
	master_volume.value = SaveManager.data.master_volume
	music_volume.value = SaveManager.data.music_volume
	sfx_volume.value = SaveManager.data.sfx_volume


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneManager._change_scene(MAIN_MENU)


func _on_use_timer_button_up() -> void:
	SaveManager.data.use_timer = use_timer.button_pressed


func _on_master_volume_drag_ended(value_changed: bool) -> void:
	SaveManager.data.master_volume = master_volume.value
	var master_index : int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(master_index, master_volume.value)


func _on_music_volume_drag_ended(value_changed: bool) -> void:
	SaveManager.data.music_volume = music_volume.value
	var music_index : int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(music_index, music_volume.value)


func _on_sfx_volume_drag_ended(value_changed: bool) -> void:
	SaveManager.data.sfx_volume = sfx_volume.value
	var sfx_index : int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_linear(sfx_index, sfx_volume.value)


func _on_reset_save_data_button_up() -> void:
	SaveManager.delete_save_data()
	use_timer.button_pressed = SaveManager.data.use_timer


func _on_back_button_up() -> void:
	SceneManager._change_scene(MAIN_MENU)
