extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal loading_initialized
signal loading_cleared

func _ready():
	print("me")
	BaseGame.load_success.connect(clear)
	animation_player.play("start")
	await animation_player.animation_finished
	loading_initialized.emit()

func clear():
	animation_player.play("clear")
	await animation_player.animation_finished
	loading_cleared.emit()
	queue_free()
	

