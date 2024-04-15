@tool
class_name Portrait extends Sprite2D

var animation_player: AnimationPlayer = AnimationPlayer.new()
var animation_library: AnimationLibrary = AnimationLibrary.new()
var animation_move: Animation = Animation.new()
var animation_beep: Animation = Animation.new()
var old_position_index: int = 1

@onready var tween: Tween

var first_animate: bool = true
var is_resized: bool = false
const GRID_SEGMENTS = 6


func _init():

	if not get_texture():
		set_texture(preload("PortraitPlaceholder.png"))
	
	if Engine.is_editor_hint():
		return
	

	DialogueStates.on_spawn_character.connect(spawn)
	DialogueStates.on_change_character_position.connect(move)
	DialogueStates.on_despawn_character.connect(despawn)
	DialogueStates.on_character_emotion.connect(react)
	DialogueStates.on_flip_character.connect(flip)
	animation_library.add_animation("beep", animation_beep)
	animation_player.add_animation_library("anime_packets", animation_library)
	add_child(animation_player)
	hide()

func _ready():
	if (Engine.is_editor_hint()):
		return
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	var gd_texture = preload("PortraitPlaceholder.png")
	
	print(gd_texture) 
	# prepare BUZZ animation
	var beep_index = animation_beep.add_track(Animation.TYPE_VALUE)
	animation_beep.track_set_path(beep_index, "%" + name + ":offset:x")
	animation_beep.track_insert_key(beep_index, 0, 30.0)
	animation_beep.track_insert_key(beep_index, 0.05, -30.0)
	animation_beep.track_insert_key(beep_index, 0.1, 30.0)
	animation_beep.track_insert_key(beep_index, 0.15, -30.0)
	animation_beep.track_insert_key(beep_index, 0.2, 30.0)
	animation_beep.track_insert_key(beep_index, 0.25, -30.0)
	animation_beep.track_insert_key(beep_index, 0.3, 0.0)




func _process(_delta):	
	# Get parent size (just make sure that the parent node [any type] is spread across the viewport)
	if (Engine.is_editor_hint() || not is_resized):
		is_resized = true
		var viewport_size = get_parent().size
		var sui_size = texture.get_size()
		scale = Vector2(viewport_size.y / sui_size.y , viewport_size.y / sui_size.y)
	
	
func spawn(character_name: String, character_position: int):
	var viewport_size = get_parent().size
	var grid_segments_size = viewport_size.x / GRID_SEGMENTS

	if (character_name == name):
		show()
		position = Vector2(float((grid_segments_size * character_position) - (grid_segments_size / 2)), position.y)
		old_position_index = character_position
		modulate = Color(1, 1, 1, 0)
		offset.y = 50
		first_animate = false
		tween.parallel().tween_property(self, "offset", Vector2(offset.x, 0), 0.5)
		tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

	#tween.stop()

func despawn(character_name: String, _duration: float):
	if (character_name == name):
		# Reference: https://docs.godotengine.org/en/stable/classes/class_tween.html
		if tween:
			tween.kill()
		tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(self, "offset", Vector2(offset.x, 50), 0.5)
		tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	
func react(character_name: String, emotion: String, _duration: float):
	if not (character_name == name):
		return
	
	match (emotion):
		"buzz":
			animation_player.play("anime_packets/beep")

func flip(character_name: String, flip: bool):
	if character_name == name:
		flip_h = flip
		
func move(character_name: String, character_position: int, duration: float):
	

	if (character_name != name || !character_position):
		return 

	# Reference: https://docs.godotengine.org/en/stable/classes/class_tween.html
	if tween:
		tween.kill()
		
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	
	var viewport_size = get_parent().size
	var grid_segments_size = viewport_size.x / GRID_SEGMENTS

	print(Vector2(float((grid_segments_size * character_position) - (grid_segments_size / 2)), position.y))
	tween.parallel().tween_property(self, "position", Vector2(float((grid_segments_size * character_position) - (grid_segments_size / 2)), position.y), duration)
	old_position_index = character_position

	

