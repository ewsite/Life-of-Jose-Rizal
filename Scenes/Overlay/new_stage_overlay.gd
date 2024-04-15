extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var nso_stage_number_label = %NSOStageNumberLabel
@onready var nso_stage_name_label = %NSOStageNameLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	nso_stage_number_label.text = "Stage " + str(GameStats.quests_catalog.get("current_stage"))
	nso_stage_name_label.text = str(Quest.current_quest_info.name)
	animation_player.play("show")
	await animation_player.animation_finished
	await get_tree().create_timer(3.0).timeout
	animation_player.play("hide")
	await animation_player.animation_finished
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
