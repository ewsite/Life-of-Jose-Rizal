extends CanvasLayer

var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.UI

func reset_game():
	Quest.reset_chapter()

func back_to_main_menu():
	Quest.reset_chapter(false)
	BaseGame.load_scene('res://Scenes/main_menu.tscn')
