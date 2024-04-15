extends Window

@onready var stage_num = $Control/MarginContainer/VBoxContainer/StageContainer/StageNum
@onready var quest_num = $Control/MarginContainer/VBoxContainer/QuestContainer/QuestNum

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	Quest.started.connect(reload)
	Quest.quest_updated.connect(reload_update)
	Quest.stopped.connect(hide)

func reload_update(_machi):
	reload()
func reload():
	stage_num.text = str(GameStats.quests_catalog.get("current_stage"))
	quest_num.text = str(GameStats.quests_catalog.get("current_quest"))
	
func _on_close_requested():
	hide()

func submit():
	GameStats.quests_catalog.current_stage = int(stage_num.text)
	GameStats.quests_catalog.current_quest = int(quest_num.text)
	DialogueStates.force_stop()
	Quest.load_quest()
	
