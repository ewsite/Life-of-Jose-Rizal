extends CanvasLayer


var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.DIALOGUE

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("start")
	await animation_player.animation_finished
	Quest.quest_complete()


func skip_intro():
	Quest.quest_complete()
