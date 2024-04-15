extends Control

var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.UI

@onready var main_menu_button = $VBoxContainer2/MainMenuButton
@onready var restart_button = $VBoxContainer2/RestartButton


func back_to_main_menu():
	GameProps.restart_game(false)
	BaseGame.load_scene("res://Scenes/main_menu.tscn")


func restart_game():
	GameProps.restart_game(true)
