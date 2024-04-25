extends Node


# Preloaded UI's
var front_ui: CanvasLayer = preload("res://UI/front_ui.tscn").instantiate()
var pause_ui: CanvasLayer = preload("res://Scenes/pause_menu.tscn").instantiate()
var game_over_ui: CanvasLayer = preload("res://Scenes/game_over.tscn").instantiate()
var settings_ui: CanvasLayer = preload("res://Scenes/settings.tscn").instantiate()
var load_ui: CanvasLayer = preload("res://Scenes/load_game.tscn").instantiate()
var cheats: CanvasLayer = preload("res://Scenes/Cheats/cheats.tscn").instantiate()

# Preloaded Loading Transition Overlays
var loading_overlays: Dictionary = {
	LOADING_TYPE.DEFAULT: preload("res://UI/LoadingScreens/default.tscn").instantiate(),
	LOADING_TYPE.FADE_BLACK: preload("res://UI/LoadingScreens/fade_black.tscn").instantiate()
}

# Containers for Preloaded UI's
var game_scene: Node = Node.new()
var ui: Node = Node.new()
var game_props_ui: Node = Node.new()
var overlay_ui: Node = Node.new()
var loading_scene: Node = Node.new()
var current_scene

enum LOADING_TYPE {DEFAULT, FADE_BLACK}
enum SCENE_TYPE {MAP, UI, ASSESSMENT, DIALOGUE}

signal load_success

func load_scene(scene_file: String, loading_type: LOADING_TYPE = LOADING_TYPE.FADE_BLACK) -> void:
	var on_ready: bool
	var scene_type: SCENE_TYPE
	
	var transition_scene = _load_loading_transition_overlay(loading_type)


	front_ui.reset()
	game_over_ui.hide()	
	
	# Let's add a delay just for you motherfuckers
	ResourceLoader.load_threaded_request(scene_file)
	
	# Wait for transition overlay to animate in before changing scene on background
	await transition_scene.loading_initialized
	Trivia.stop_trivia()	
	
	if current_scene:
		current_scene.queue_free()
		current_scene = null
		
	while not on_ready:
		var scene_load_status = ResourceLoader.load_threaded_get_status(scene_file)
		match scene_load_status:
			ResourceLoader.THREAD_LOAD_LOADED:
				on_ready = true
				current_scene = ResourceLoader.load_threaded_get(scene_file).instantiate()
				scene_type = current_scene.scene_type if "scene_type" in current_scene else SCENE_TYPE.UI
				set_game_props_process(scene_type)
				game_scene.add_child(current_scene)
				load_success.emit()
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				get_tree().quit(32)
			ResourceLoader.THREAD_LOAD_FAILED:
				get_tree().quit(1)


func set_game_props_process(scene_type: SCENE_TYPE) -> void:
	match scene_type:
		SCENE_TYPE.MAP:
			Trivia.show_trivia_visibility()
			pause_ui.hide()
			front_ui.show_panel()
			pause_ui.process_mode = Node.PROCESS_MODE_ALWAYS
			GameStats.current_scene_map = true
			GameStats.current_map_name = current_scene.name
		SCENE_TYPE.ASSESSMENT:
			Trivia.hide_trivia_visibility()
			pause_ui.hide()
			front_ui.show_panel()
			front_ui.deactivate_actions_ui()
			pause_ui.process_mode = Node.PROCESS_MODE_ALWAYS
		SCENE_TYPE.UI:
			Trivia.hide_trivia_visibility()
			pause_ui.hide()
			front_ui.hide_panel()
			pause_ui.process_mode = Node.PROCESS_MODE_DISABLED
		SCENE_TYPE.DIALOGUE:
			Trivia.hide_trivia_visibility()
			pause_ui.hide()
			front_ui.hide_panel()
			pause_ui.process_mode = Node.PROCESS_MODE_DISABLED

func game_over() -> void:
	GameStats.erase_player_position(GameStats.current_map_name)
	current_scene.queue_free()
	current_scene = null
	front_ui.hide_panel()
	game_over_ui.show()


func _load_loading_transition_overlay(loading_type: LOADING_TYPE) -> CanvasLayer:
	var loading_screen: CanvasLayer = loading_overlays.get(loading_type).duplicate()
	loading_scene.add_child(loading_screen)
	return loading_screen

func on_update_quest(quest) -> void:
	BaseGame.front_ui.quest_title_label.text = quest.name
	BaseGame.front_ui.quest_description_label.text = quest.description
	
func flush_canvas() -> void:
	for child in overlay_ui.get_children():
		child.queue_free()
		
func _init() -> void:
	# Naming core nodes
	game_scene.name = "GameScene"
	loading_scene.name = "LoadingScene"
	ui.name = "UI"
	# Add additional nodes to core node
	ui.add_child(front_ui)
	ui.add_child(pause_ui)
	ui.add_child(game_over_ui)
	ui.add_child(settings_ui)
	ui.add_child(load_ui)
	
	# Change some other properties
	front_ui.hide()
	pause_ui.hide()
	game_over_ui.hide()
	
	# Push core nodes to the base game
	add_child(ui)
	add_child(game_scene)
	add_child(loading_scene)
	add_child(cheats)
	add_child(overlay_ui)
	
	# Connect signal from Quest.gd to give an update
	Quest.quest_updated.connect(on_update_quest)


