extends CanvasLayer

@onready var question_label: Label = %QuestionLabel
@onready var answer_input: LineEdit = %AnswerInput
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = %Timer
@onready var timer_label: Label = %TimerLabel
@onready var control: Control = $Control


func _ready():
	control.hide()
	
func _process(_delta):
	timer_label.text = str(floor(timer.time_left))
	
func fire(question: String, duration: int = 0):
	timer.wait_time = duration
	animation_player.play("show")
	question_label.text = question
	await animation_player.animation_finished
	timer.start()

func submit(is_failed: bool):
	var answer: String = answer_input.text
	var current_scene = DialogueStates.current_dialogue_balloon
	if not current_scene.has_method("skip_dialogue_line"):
		assert(false, "OHNONONONONO -> Current Dialogue Balloon not found.")
		return
		
	if not timer.is_stopped():
		timer.stop()
		
	if not is_failed:
		DialogueStates.player_answer = answer.to_lower()
	
	answer_input.text = ""
	animation_player.play("hide")
	# Wait half the duration of animation player before next dialogueline
	await get_tree().create_timer(0.25).timeout
	current_scene.skip_dialogue_line()

func timeout():
	submit(true)
