extends Node


const SAVEBIN_PATH: String = "user://saves"
const SAVEBIN_FILENAME: String = "user://saves/save.bin"
const GAME_CONFIG_FILENAME: String = "user://config.bin"

const AVAILABLE_INPUT_MAPS = [
								"player_walk_right", 
								"player_walk_left",
								"player_walk_up",
								"player_walk_down",
								"player_interact",
								"player_run"	
							]
							
var configs: Dictionary = {
	"input": {} as Dictionary,
	"display": {} as Dictionary,
	"gameplay": {} as Dictionary
}

# Gameplay Props
var show_offscreen_marker: bool = true

var current_save_path: String

	
func _init():
	if not DirAccess.dir_exists_absolute(SAVEBIN_PATH):
		DirAccess.make_dir_absolute(SAVEBIN_PATH)


func is_mobile() -> bool:
	var os_name: String = OS.get_name()
	return os_name == "iOS" || os_name == "Android"
	
func get_saved_lists() -> Array:
	var filtered_files: Array = []
	for file in DirAccess.get_files_at(SAVEBIN_PATH):
		if file.get_extension() != "bin":
			continue

		var fp = FileAccess.open(SAVEBIN_PATH + "/" + file, FileAccess.READ)
		var contents: Dictionary = fp.get_var(true)
		fp.close()
		
		filtered_files.push_back({
			"filename": file,
			"player_name": contents.player_name,
			"quest_name": contents.quests_catalog.current_quest_name
		})

	return filtered_files
	
func _ready():
	if game_config_exists():
		var fp = FileAccess.open(GAME_CONFIG_FILENAME, FileAccess.READ)
		configs = fp.get_var(true).duplicate()
		fp.close()
	else:
		save_game_config()
	load_game_config()


# ===========================
#     GAME CONFIGURATIONS 
# ===========================
func load_game_config() -> void:
	# Display
	
	show_offscreen_marker = configs.gameplay.get("show_offscreen_marker")
	DisplayServer.window_set_mode(configs.display.get("fullscreen"))
	for action in InputMap.get_actions():
		if (action in AVAILABLE_INPUT_MAPS):
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, configs.input.get(action))
	

func save_game_config() -> void:
	var fp: FileAccess = FileAccess.open(GAME_CONFIG_FILENAME, FileAccess.WRITE)
	for c in AVAILABLE_INPUT_MAPS:
		configs.input[c] = InputMap.action_get_events(c).back().duplicate()
	configs.gameplay = {
		"show_offscreen_marker": show_offscreen_marker
	}
	configs.display = {
		"fullscreen": DisplayServer.window_get_mode()
	}
	fp.store_var(configs, true)
	
func game_config_exists() -> bool:
	return FileAccess.file_exists(GAME_CONFIG_FILENAME)
	

# ===========================
#      SAVE GAME ACTIONS
# ===========================
func save_game_exists() -> bool:
	return DirAccess.get_files_at(SAVEBIN_PATH).size() > 0

func save_game_size() -> int:
	var valid_save_files_size: int = 0
	var files = DirAccess.get_files_at(SAVEBIN_PATH)
	for file in files:
		if file.get_extension() == "bin":
			valid_save_files_size += 1
	return valid_save_files_size

func delete_save_game(filename: String) -> bool:
	var save_file_path = SAVEBIN_PATH + "/" + filename
	if not FileAccess.file_exists(save_file_path):
		printerr("[LOADGAME][ERROR] -> File Path: " + save_file_path + " doesn\'t exists.")
		return false
	DirAccess.remove_absolute(save_file_path)
	return true

# ===========================
#      MAIN MENU ACTIONS
# ===========================
func save_game(as_new: bool = false):
	var save_game_file_size = save_game_size()

	if as_new:
		current_save_path = SAVEBIN_PATH + "/save" + str(save_game_file_size + 1) + ".bin"
	
	var fp = FileAccess.open(current_save_path, FileAccess.WRITE)
	fp.store_var(GameStats.export(), true)
	fp.close()

func new_game(player_name: String = "Rodel"):
	GameStats.reset()
	GameStats.player_name = player_name
	save_game(true)
	Quest.load_quest()

func load_game(filename: String):
	var save_file_path = SAVEBIN_PATH + "/" + filename

	if not FileAccess.file_exists(save_file_path):
		printerr("[LOADGAME][ERROR] -> File Path: " + save_file_path + " doesn\'t exists.")
		return
	
	var fp = FileAccess.open(save_file_path, FileAccess.READ)
	var contents: Dictionary = fp.get_var(true)
	fp.close()
	GameStats.import(contents)	
	current_save_path = save_file_path
	# Load Quest
	Quest.load_quest()


func restart_game(reload_quest: bool = true) -> void:
	GameStats.reset()
	GameStats.quests_catalog.current_stage = 1
	save_game()

	if (reload_quest):
		Quest.load_quest()

	
