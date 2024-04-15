extends "res://Quests/dialogue.gd"

var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.DIALOGUE

func _ready():
	var current_dir: String = get_script().resource_path.get_base_dir()
	initialize_dialogue(load(current_dir + "/index.dialogue"))
	
