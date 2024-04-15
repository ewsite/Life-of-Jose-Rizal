extends CanvasLayer

var is_activity: bool
var is_dialogue_aborted: bool

func initialize_dialogue(dialogue_script: DialogueResource, dialogue_type: DialogueStates.DIALOGUE_TYPE = DialogueStates.DIALOGUE_TYPE.DEFAULT):
	DialogueStates.start(dialogue_script, dialogue_type)
	DialogueManager.dialogue_ended.connect(completed)
	DialogueStates.on_abort_dialogue.connect(abort)
	
func abort():
	Quest.load_quest()
	is_dialogue_aborted = true

# When the dialogue was completed, back to the map
func completed(_a):
	if not GameStats.player_dead() && !is_dialogue_aborted:
		Quest.quest_complete()
	
