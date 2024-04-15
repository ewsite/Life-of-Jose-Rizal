extends Button


func _on_pressed():
	var _k = InputEventAction.new()
	_k.action = "player_interact"
	_k.pressed = true
	Input.parse_input_event(_k)
