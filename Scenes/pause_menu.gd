extends CanvasLayer

func _ready():
	visible = false
	
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		togglePause()

func togglePause():
	if (get_tree().paused):
		get_tree().paused = false
		visible = false
	else:
		get_tree().paused = true
		visible = true

func continue_the_game():
	togglePause()


func back_to_main_menu():
	get_tree().paused = false
	GameProps.save_game()
	DialogueStates.force_stop()
	Quest.flush()
	BaseGame.flush_canvas()
	BaseGame.load_scene("res://Scenes/main_menu.tscn")


func go_to_settings():
	BaseGame.settings_ui.show_panel()
