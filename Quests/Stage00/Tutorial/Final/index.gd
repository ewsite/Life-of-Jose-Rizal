extends Control


var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.DIALOGUE

@onready var coundown_timer = $CoundownTimer
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	coundown_timer.text = "Continue in " + str(int(timer.time_left)) + "..."


func jump():
	Quest.quest_complete()
