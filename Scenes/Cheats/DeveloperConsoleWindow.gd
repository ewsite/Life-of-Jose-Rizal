extends Window

@onready var cheat_quest_list_container = %CheatQuestListContainer
@onready var cheat_change_quest_container = %CheatChangeQuestContainer

func _ready():
	Quest.started.connect(quest_started)
	Quest.stopped.connect(quest_stopped)
	cheat_change_quest_container.hide()
	hide()


func quest_started():
	cheat_change_quest_container.show()
	
func quest_stopped():
	cheat_change_quest_container.hide()


