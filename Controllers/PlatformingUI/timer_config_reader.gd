extends Panel

func _ready() -> void:
	visible = SaveManager.data.use_timer 
