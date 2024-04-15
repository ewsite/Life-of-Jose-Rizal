extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("start")
	await animation_player.animation_finished
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://info.tscn")
