extends Control


# Called when the node enters the scene tree for the first time.
func _init():
	if (not DisplayServer.is_touchscreen_available()):
		hide()
