extends Control

var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.UI

@onready var load_game_button: Button = %LoadGameButton
@onready var new_game_button: Button = %NewGameButton
@onready var animated_sprite_2d: AnimatedSprite2D = $BG/Control/AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var new_game_popup = $BG/LogoContainer/NewGamePopup
@onready var ngp_input = $BG/LogoContainer/NewGamePopup/NewGamePopupContainer/VBoxContainer/NGPInput

func _ready():
	animated_sprite_2d.speed_scale = 1.7
	if (GameProps.save_game_exists()):
		load_game_button.show()
	else:
		load_game_button.hide()

func new_game():
	GameProps.new_game(ngp_input.text)
	
func play_game():
	animation_tree.set("parameters/popup_blend/blend_amount", 1.0)
	animation_tree.set("parameters/hide_popup_seek/seek_request", 0.0)

func quit_game():
	get_tree().quit()

func load_game():
	BaseGame.load_ui.show_panel()

func go_to_settings():
	BaseGame.settings_ui.show_panel()

func cancel_popup():
	ngp_input.text = ""
	animation_tree.set("parameters/popup_blend/blend_amount", -1.0)
	animation_tree.set("parameters/show_popup_seek/seek_request", 0.0)


