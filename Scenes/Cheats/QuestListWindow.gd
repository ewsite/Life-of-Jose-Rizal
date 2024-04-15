extends Window

@onready var quest_list_container = $Control/MarginContainer/QuestListContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	var catalog = Quest.chapters_catalog
	
	for child in quest_list_container.get_children(true):
		child.queue_free()

	for chapter_index in range(catalog.size()):
		var chapter = catalog[chapter_index] as Dictionary
		var quests = chapter.get("quests") as Array
		var stage_label: Label = Label.new()
		stage_label.text = "Stage " + str(chapter_index) + ": " + chapter.get("name")
		quest_list_container.add_child(stage_label)
		for quest_index in range(quests.size()):
			var quest = quests[quest_index] as Dictionary
			var quest_label: Label = Label.new()
			quest_label.text = "\t Scene " + str(quest_index) + ": " + quest.get("name")
			quest_list_container.add_child(quest_label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_close_requested():
	hide()
