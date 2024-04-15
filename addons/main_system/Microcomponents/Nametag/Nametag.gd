@tool
extends Node2D

@export var label_name: String = "Rodel"
@export var is_quest: bool = false

#@onready var main_container: VBoxContainer = $Control/VBoxContainer
#@onready var quest_indicator = $Control/VBoxContainer/QuestIndicator
@onready var name_label = $Control/PanelContainer/Name
#@onready var quest_mark_indicator = $Control/VBoxContainer/QuestIndicator/QuestMarkIndicator

const NAMETAG_QUEST_INDICATOR: CompressedTexture2D = preload("NametagQuestIndicator.png")

# Called when the node enters the scene tree for the first time.
#func _ready():
	#quest_mark_indicator.texture = NAMETAG_QUEST_INDICATOR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	name_label.text = label_name
	#if is_quest:
		#quest_indicator.show()
	#else:
		#quest_indicator.hide()

