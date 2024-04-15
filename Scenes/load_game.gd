extends CanvasLayer

@onready var save_game_lists: VBoxContainer = %SaveGameLists
@onready var animation_player = $AnimationPlayer

var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.UI
var lists: Array

func prepare_saved_list():
	for list in save_game_lists.get_children(true):
		list.call_deferred("queue_free")
	
	lists = GameProps.get_saved_lists()
	
	# If no save file, hide this panel and reload main menu to
	# remove load game button
	if (lists.size() == 0):
		hide_panel()
		BaseGame.load_scene("res://Scenes/main_menu.tscn")
		return
		
	for list_index in range(lists.size()):
		var new_container: HBoxContainer = HBoxContainer.new()
		var new_button: Button = Button.new()
		var new_delete_button: Button = Button.new()
		var list: Dictionary = lists[list_index]
		
		new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_delete_button.text = "Delete"
		new_button.text = lists[list_index].player_name + " - " + lists[list_index].quest_name
		
		new_button.pressed.connect(load.bind(list_index))
		new_delete_button.pressed.connect(delete.bind(list_index))
		
		new_container.add_child(new_button)
		new_container.add_child(new_delete_button)
		save_game_lists.add_child(new_container)

func delete(save_game_index: int):
	GameProps.delete_save_game(lists[save_game_index].filename)
	prepare_saved_list()
	
func load(save_game_index: int):
	GameProps.load_game(lists[save_game_index].filename)
	hide_panel()
func show_panel():
	process_mode = Node.PROCESS_MODE_ALWAYS
	prepare_saved_list()
	animation_player.play("show")
	await animation_player.animation_finished
func hide_panel():
	animation_player.play("hide")
	await animation_player.animation_finished
	process_mode = Node.PROCESS_MODE_DISABLED
	
func back_to_main_menu():
	hide_panel()
