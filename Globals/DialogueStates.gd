extends Node

const DEFAULT_DURATION: float = 0.5


var is_dialogue_running: bool
var dialogue_ui: Node = Node.new()
var current_dialogue_balloon: Node = null
var current_dialogue_type: DIALOGUE_TYPE = DIALOGUE_TYPE.DEFAULT
var assessment_node: CanvasLayer = null

signal on_emit_signal
signal on_character_emotion
signal on_spawn_character
signal on_despawn_character
signal on_change_character_position
signal on_activity_finished
signal on_abort_dialogue
signal on_slide_changed
signal on_flip_character

var player_answer: String
var correct_answers_score: int = 0
var wrong_answers_score: int = 0

enum DIALOGUE_TYPE {
	DEFAULT,
	INLINE,
	ASSESSMENT_MULTIPLE_CHOICE,
	ASSESSMENT_IDENTIFICATION,
	ASSESSMENT_MULTIPLE_CHOICE_TIMER,
	ASSESSMENT_IDENTIFICATION_TIMER
}

func _ready():
	add_child(dialogue_ui)
	DialogueManager.dialogue_ended.connect(stop)
	
func start(resource: DialogueResource, dialogue_type: DIALOGUE_TYPE):
	
	current_dialogue_type = dialogue_type
	
	match dialogue_type:
		DIALOGUE_TYPE.ASSESSMENT_IDENTIFICATION:
			current_dialogue_balloon = DialogueManager.show_dialogue_balloon(resource)
			assessment_node = preload("res://UI/Dialogue/Assessment/identification.tscn").instantiate()
		DIALOGUE_TYPE.ASSESSMENT_IDENTIFICATION_TIMER:
			current_dialogue_balloon = DialogueManager.show_dialogue_balloon(resource)
			assessment_node = preload("res://UI/Dialogue/Assessment/identification.tscn").instantiate()
		DIALOGUE_TYPE.INLINE:
			current_dialogue_balloon = DialogueManager.show_dialogue_balloon_scene("res://UI/Dialogue/inline_balloon.tscn", resource)
		_:
			current_dialogue_balloon = DialogueManager.show_dialogue_balloon(resource)
	if assessment_node:
		dialogue_ui.add_child(assessment_node)
		
	is_dialogue_running = true

func stop(_hmmm):
	is_dialogue_running = false
	
	if current_dialogue_type == DIALOGUE_TYPE.INLINE:
		Quest.quest_complete(false)
	
	current_dialogue_type = DIALOGUE_TYPE.DEFAULT
	if assessment_node != null:
		assessment_node.queue_free()
		assessment_node = null
		
func force_stop():
	if current_dialogue_balloon != null:
		current_dialogue_balloon.queue_free()
		current_dialogue_balloon = null
	stop(null)
	

func abort_dialogue():
	on_abort_dialogue.emit()

func do_emit_signal(prop: String):
	on_emit_signal.emit(prop)
	
func emote_character(character: String, emotion: String, duration: float = 0.5):
	on_character_emotion.emit(character, emotion, duration)

func spawn_character(character: String, position: int = 1):
	on_spawn_character.emit(character, position)

func flip_character(character: String, flip: bool):
	on_flip_character.emit(character, flip)
	
func change_character_position(character: String, position: int, duration: float = 0.5):
	on_change_character_position.emit(character, position, duration)

func despawn_character(character: String, duration: float = 0.5):
	on_despawn_character.emit(character, duration)

func change_slide(slide_number: int):
	on_slide_changed.emit(slide_number)
	
func activity_finished():
	on_activity_finished.emit()

func clear_player_answer():
	player_answer = ""

func fire_identification_question(question: String):
	var is_timer_activated: bool = current_dialogue_type == DIALOGUE_TYPE.ASSESSMENT_IDENTIFICATION_TIMER
	
	if assessment_node == null:
		print_debug("[FIRE][DIALOGUESTATES]: Assessment \"identification\" not found.")
		return
	
	if not assessment_node.has_method("fire"):
		print_debug("[FIRE][DIALOGUESTATES]: AssessmentNode \"identification\" doesn't have a fire method. Fix this.")
		return
		
	assessment_node.fire(question, 10 if is_timer_activated else 0)
