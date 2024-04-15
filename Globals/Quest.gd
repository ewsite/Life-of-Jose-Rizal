extends Node

var NEW_STAGE_OVERLAY = preload("res://Scenes/Overlay/new_stage_overlay.tscn").instantiate()

const AVAILABLE_CHAPTERS_PATH = "res://Quests/available_stages.json"

var available_stages: Array
var chapters_catalog: Array

var game_complete_node

var current_quest_path: String = ""
var current_stage_info: Dictionary
var current_quest_info: Dictionary

var is_quest_running: bool

# Signals
signal started
signal stopped
signal quest_updated
signal game_completed
signal quest_completed

# Loads quest information
func _init() -> void:
	var fp = FileAccess.open(AVAILABLE_CHAPTERS_PATH, FileAccess.READ)
	available_stages = JSON.parse_string(fp.get_as_text())
	fp.close()
	load_chapter()

# Reset and flush quest data
func flush() -> void:
	current_quest_path = ""
	current_stage_info.clear()
	current_quest_info.clear()
	is_quest_running = false
	stopped.emit()

# Loads a chapter ( STRICTLY CALLED THIS METHOD ONCE THANK YOU :) )
func load_chapter() -> void:
	for chapter in available_stages:
		var fp = FileAccess.open("res://Quests/" + chapter, FileAccess.READ)
		chapters_catalog.push_back(JSON.parse_string(fp.get_as_text()))
		fp.close()

# Loads a quest. It can also be used to restart specific quest.
func load_quest(reload_map: bool = true) -> void:
	var catalog = GameStats.quests_catalog

	if (catalog.current_stage >= chapters_catalog.size()):
		game_complete()
		return

	current_stage_info = chapters_catalog[catalog.current_stage].duplicate()
	current_quest_info = current_stage_info.quests[catalog.current_quest].duplicate()

	var stage_path: String = current_stage_info.get("stage_path")
	var scene_path: String = current_quest_info.get("scene_path")

	current_quest_path = "res://Quests/" + stage_path + "/" + scene_path

	if current_quest_info.has("unskippable"):
		await BaseGame.load_scene(current_quest_path + "/index.tscn")
	else:
		
		if reload_map:
			var map_name: String = "res://Scenes/Maps/" + current_quest_info.target_map + "/scene.tscn"
			await BaseGame.load_scene(map_name)
		else:
			var npcs = BaseGame.current_scene.get_node("NPC").get_children()
			for npc in npcs:
				npc.is_inline_scene = false
				npc.dialogue_file = ""
				npc.scene_file = ""
				
		var current_map: Node2D = BaseGame.current_scene
		var npc = current_map.get_node("NPC/" + current_quest_info.target_node)
		var player = current_map.get_node("Player")
		
		
		# Print an error if NPC or EntryArea does not exist in the map
		if not npc:
			printerr("[Quest NPC]: No NPC named " + current_quest_info.target_node)
			printerr("Please check chapter " + str(catalog.current_stage + 1) + ", quest " + str(catalog.current_quest + 1) +".")
			return
		
		if not player:
			printerr("[Quest Player]: No Player!")
			return
		
		if current_quest_info.has("inline"):
			npc.is_inline_scene = current_quest_info.has("inline")
			npc.dialogue_file = current_quest_path + "/index.dialogue"
		else:
			npc.scene_file = current_quest_path + "/index.tscn"
			
		quest_updated.emit(current_quest_info.duplicate())
	
	catalog.current_quest_name = current_quest_info.get("name")
	
	if (catalog.current_stage > 0 && catalog.current_quest == 0):
		var dup_overlay = NEW_STAGE_OVERLAY.duplicate()
		BaseGame.overlay_ui.add_child(dup_overlay)
		
	if not is_quest_running:
		is_quest_running = true
		started.emit()


func quest_complete(reload_map: bool = true) -> void:
	var catalog = GameStats.quests_catalog
	var is_unskippable = "unskippable" in current_quest_info && current_quest_info.unskippable
	catalog.current_quest += 1
	
	if catalog.current_quest >= current_stage_info.get("quests").size():
		catalog.current_stage += 1
		catalog.current_quest = 0
		
	await load_quest(reload_map)
	quest_completed.emit(is_unskippable)


func game_complete() -> void:
	var catalog = GameStats.quests_catalog
	catalog.is_game_complete = true
	BaseGame.load_scene("res://Scenes/game_complete.tscn")
	

func reset_chapter(reload_quest: bool = true) -> void:
	var catalog = GameStats.quests_catalog
	catalog.current_quest = 0
	GameStats.reset_health()	
	if reload_quest:
		load_quest()
