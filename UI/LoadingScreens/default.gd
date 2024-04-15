extends CanvasLayer

@onready var animation_player = $AnimationPlayer

signal loading_initialized
signal loading_cleared

func _ready():
	animation_player.play("start")
	await animation_player.animation_finished
	loading_initialized.emit()

func clear():
	animation_player.play("clear")
	loading_cleared.emit()

func sheesh(anim_name):
	if (anim_name == "clear"):
		queue_free()
