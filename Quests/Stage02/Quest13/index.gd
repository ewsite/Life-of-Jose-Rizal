extends "res://Quests/dialogue.gd"

var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.DIALOGUE
@onready var animation_player = $AnimationPlayer

func _ready():
	DialogueStates.on_slide_changed.connect(play_slide)
	var current_dir: String = get_script().resource_path.get_base_dir()
	initialize_dialogue(load(current_dir + "/index.dialogue"))
	
func play_slide(slide_number: int):
	animation_player.play("slide_" + str(slide_number))
