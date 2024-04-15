extends Node
const TOTAL_HEALTH: int = 3

var player_name: String
var health: int
var score: int
var player_position: Vector2
var map_coordinates: Dictionary
var quests_catalog: Dictionary
var current_scene_map: bool
var current_map_name: String

# SIGNALS
signal on_remove_health
signal on_add_health
signal on_reset_health

func _init():
	reset()

# ===========================
#   PLAYER POSITION METHODS
# ===========================
func erase_player_position(map_name: String) -> bool:
	return map_coordinates.erase(map_name)

func get_player_position(map_name: String) -> Vector2:
	return map_coordinates.get(map_name)

func update_player_position(map_name: String, coords: Vector2) -> void:
	map_coordinates[map_name] = coords

func is_save_map_position_exists(map_name: String) -> bool:
	return map_coordinates.has(map_name)

# ===========================
#    PLAYER HEALTH METHODS
# ===========================

func reset_health() -> void:
	health = TOTAL_HEALTH
	on_reset_health.emit()

func add_health() -> bool:
	if (health < TOTAL_HEALTH):
		health += 1
		on_add_health.emit()
		return true
	return false
	
func remove_health() -> bool:
	if (health > 0):
		health -= 1
		on_remove_health.emit()
		return true
	return false

func player_dead() -> bool:
	return health == 0

# ===========================
#   IMPORT/EXPORT PROGRESS
# ===========================

func import(data: Dictionary) -> void:
	player_name = data.get("player_name")
	health = data.get("health")
	player_position = data.get("player_position")
	map_coordinates = data.get("map_coordinates")
	quests_catalog = data.get("quests_catalog")
	current_map_name = data.get("current_map_name")
	current_scene_map = data.get("current_scene_map")

func export() -> Dictionary:
	return {
		"player_name": player_name,
		"health": health,
		"player_position": player_position,
		"map_coordinates": map_coordinates,
		"quests_catalog": quests_catalog,
		"current_map_name": current_map_name,
		"current_scene_map": current_scene_map
	}.duplicate()


# ===========================
#   		RESET
# ===========================

func reset() -> void: 
	health = TOTAL_HEALTH
	score = 0
	player_position = Vector2.ZERO
	map_coordinates.clear()
	quests_catalog = {
		"current_quest_name": "",
		"current_stage": 0,
		"current_quest": 0,
		"is_game_complete": false
	}
	current_map_name = ""
	current_scene_map = false
