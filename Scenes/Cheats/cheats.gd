extends CanvasLayer

@onready var cheats_container = $CheatsContainer

@onready var cheat_quest_list_container = %CheatQuestListContainer
@onready var cheat_change_quest_container = %CheatChangeQuestContainer
@onready var developer_console_window = $CheatsContainer/DeveloperConsoleWindow
@onready var quest_list_window = $CheatsContainer/QuestListWindow
@onready var change_quest_window = $CheatsContainer/ChangeQuestWindow

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("open_cheats"):
		if visible:
			hide()
		else:
			show()

	
func show_quest_list_window():
	quest_list_window.show()
	
func show_change_quest_window():
	change_quest_window.show()

func dev_console_close_request():
	hide()


func _on_visibility_changed():
	if visible:
		developer_console_window.show()
		quest_list_window.hide()
		change_quest_window.hide()
	else:
		developer_console_window.hide()
		quest_list_window.hide()
		change_quest_window.hide()
