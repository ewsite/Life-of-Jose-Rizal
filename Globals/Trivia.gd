extends Node

var _TRIVIA_NODE = preload("res://UI/trivia.tscn").instantiate()
const _AVAILABLE_TRIVIA_SETS = "res://Trivia/available_trivias.json"

var _trivia: Array = []

func _init():
	var fp: FileAccess = FileAccess.open(_AVAILABLE_TRIVIA_SETS, FileAccess.READ);
	var trivias = JSON.parse_string(fp.get_as_text()) as Array
	
	fp.close()
	for trivia in trivias:
		fp = FileAccess.open("res://Trivia/" + trivia, FileAccess.READ)
		if fp.get_length() == 0:
			_trivia.push_back([])
		else:
			_trivia.push_back(JSON.parse_string(fp.get_as_text()))
	
	BaseGame.ui.add_child(_TRIVIA_NODE)

func _ready():
	Quest.quest_updated.connect(show_next_trivia)

func stop_trivia():
	_TRIVIA_NODE.stop()

func hide_trivia_visibility():
	_TRIVIA_NODE.hide()
	
func show_trivia_visibility():
	_TRIVIA_NODE.show()
	
func show_next_trivia(quest: Dictionary):
	var current_quest: int = GameStats.quests_catalog.get("current_quest")
	var current_stage: int = GameStats.quests_catalog.get("current_stage")
	
	if "unskippable" in quest || current_stage == 0:
		return
	
	var trivias: Array = _trivia[current_stage - 1]
	
	var filtered_trivia = trivias.filter(func(arr):
		if not "quest_for" in arr:
			return false
			 
		return arr.quest_for == current_quest
		)

	if filtered_trivia.size() > 0:
		var magic_number = randi_range(0, filtered_trivia.size() - 1)
		_TRIVIA_NODE.fire(filtered_trivia[magic_number].description)
	else:
		if trivias.size() == 0:
			return
		var magic_number = randi_range(0, trivias.size() - 1)
		_TRIVIA_NODE.fire(trivias[magic_number].description)
	
