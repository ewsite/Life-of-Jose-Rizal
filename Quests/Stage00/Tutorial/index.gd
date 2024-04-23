extends Node2D

var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.MAP

@onready var animation_player = $AnimationPlayer
@onready var player = $Player
@onready var fui = BaseGame.front_ui

@onready var npc = $NPC

var requirement_keypress: String

var playlists: Array = ["start", "hud", "character", "character_left", "character_down", "character_up", "follow_quest", "interact", "ending"]
var playlists_mobile: Array = ["start", "hud_mobile", "character_mobile", "character_left_mobile", "character_down_mobile", "character_up_mobile", "follow_quest", "interact", "ending"]
var current_playlist: String
var playlist_index: int = 0
var map: bool = true
var already_played: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	fui.quest_title_label.text = ""
	fui.quest_description_label.text = ""
	play_something()

func play_something(skip: bool = false):
	if (playlist_index > 0 && not skip):
		await get_tree().create_timer(2.0).timeout
	
	if (playlist_index > playlists.size()):
		return 
	
	if (DisplayServer.is_touchscreen_available()):
		current_playlist = str(playlists_mobile[playlist_index])
	else:
		current_playlist = str(playlists[playlist_index])
		
	animation_player.play(current_playlist)
	playlist_index = playlist_index + 1

func send_requirement_keypress(keypress: String):
	requirement_keypress = keypress

func hit_sample_quest():
	fui.quest_title_label.text = "Subukan mo lang"
	fui.quest_description_label.text = "Lumapit ka kay Mark"
	npc.scene_file = "res://Quests/Stage00/Tutorial/Final/index.tscn"
	
	
func _input(event):
	if (not requirement_keypress.length()):
		return
	
	if (DisplayServer.is_touchscreen_available()):
		print(playlists[playlist_index	])
		if player.velocity.x < 0 && requirement_keypress == "player_walk_left":
			animation_player.play("plop_reset")
			requirement_keypress = ""
			play_something()
		elif player.velocity.x > 0  && requirement_keypress == "player_walk_right":
			animation_player.play("plop_reset")
			requirement_keypress = ""
			play_something()
			
		if player.velocity.y < 0 && requirement_keypress == "player_walk_up":
			animation_player.play("plop_reset")
			requirement_keypress = ""
			play_something()
		elif player.velocity.y > 0 && requirement_keypress == "player_walk_down":
			animation_player.play("plop_reset")
			requirement_keypress = ""
			play_something()

	else:
		if (event.is_action_pressed(requirement_keypress)):
			animation_player.play("plop_reset")
			requirement_keypress = ""
			play_something()
			
		
func hit_interact():
	if (not already_played):
		play_something(true)
		already_played = true
	fui.show_actions_button("interact")
	

func unhit_interact():
	fui.hide_actions_button()

func complete():
	Quest.quest_complete()
