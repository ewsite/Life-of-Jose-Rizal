extends CanvasLayer
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var description_node = %Description

var is_running: bool
func _ready():
	timer.timeout.connect(stop)

func fire(description: String):
	is_running = true
	await get_tree().create_timer(4.0).timeout
	
	if not is_running:
		return
		
	description_node.text = description
	timer.start()
	animation_player.play("in")

func stop():
	if not timer.is_stopped():
		timer.stop()
	if is_running:
		animation_player.play("out")
	is_running = false


	
