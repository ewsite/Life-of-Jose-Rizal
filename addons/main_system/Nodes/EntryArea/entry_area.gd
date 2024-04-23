# Next feature to be added:
# ---------------------------------------------------------
# AnimatedNPCBody
#

@tool
class_name EntryArea extends Area2D

@export_category("EntryArea Properties")
@export_group("EntryArea Transform")
@export_range(0, 200, 1) var entry_area_scale: int = 100
@export var flip_horizontally: bool = false
@export var flip_vertically: bool = false
@export_group("Appearance")
@export var sprite_texture: Texture2D = preload("NPCPlaceholder.png")
@export var animated_entry_area_body: AnimatedSprite2D
@export_group("When Interact Happens?")
@export var is_inline_scene: bool
@export var force_complete: bool
@export_file("*.tscn") var scene_file: String
@export_file("*.dialogue") var dialogue_file: String
@export_group("Others")
@export var player_node: Node2D

@onready var offscreen_marker: Node2D = $"OffScreenMarker"
@onready var interaction_collision_area: CollisionShape2D = $"InteractionCollisionArea"
@onready var body: Sprite2D = $Body

# Available Signals
signal enter_interact
signal exit_interact


var size: Vector2 = Vector2(0, 0)
var ready_to_interact: bool = false
var interact_from
const INTERACTION_AREA_SCALE: float = 4.0


func _enter_tree():

	if get_child_count(true):
		return
	var dz_offscreen_marker: Node2D = preload("../../Microcomponents/OffScreenMarker/OffScreenMarker.tscn").instantiate()
	var dz_interaction_collision_area: CollisionShape2D = CollisionShape2D.new()
	var dz_ica_shape2d: RectangleShape2D = RectangleShape2D.new()
	var dz_body: Sprite2D = Sprite2D.new()
	
	# Changing name
	dz_body.name = "Body"
	dz_interaction_collision_area.name = "InteractionCollisionArea"
	dz_offscreen_marker.name = "OffScreenMarker"

	# Change props
	dz_body.texture = sprite_texture
	dz_offscreen_marker.target_node = player_node
	dz_offscreen_marker.root_node = self
	# Add boundaries to colliders
	dz_interaction_collision_area.shape = dz_ica_shape2d
	body_entered.connect(want_to_interact)
	body_exited.connect(not_want_to_interact)
	
	# Add child to the main node
	add_child(dz_body)
	add_child(dz_interaction_collision_area)
	add_child(dz_offscreen_marker)

func _ready():
	if not Engine.is_editor_hint():
		body.set_modulate(Color("ffffff00"))
	else:
		body.set_modulate(Color("ffffff"))
	change_properties()
		
func _process(_delta):
	offscreen_marker.enabled = true if (scene_file || dialogue_file || force_complete) && player_node && not DialogueStates.is_dialogue_running else false	
	if (Engine.is_editor_hint()):
		change_properties()
	
func change_properties():
	var crack_scale = float(entry_area_scale) * 0.01
	var texture_size: Vector2

	if not body && not sprite_texture:
		return
		
	texture_size = sprite_texture.get_size()
	body.texture = sprite_texture
	body.set_scale(Vector2(crack_scale, crack_scale))
	texture_size = Vector2(texture_size.x * crack_scale, texture_size.y * crack_scale)
	body.flip_h = flip_horizontally
	body.flip_v = flip_vertically
	body.show()

	# Set size of the collision based on the size of custom texture.
	interaction_collision_area.shape.set_size(texture_size)
	

func _input(event):
	if (Engine.is_editor_hint() || not ready_to_interact):
		return
		
	if (event.is_action_pressed("player_interact") && scene_file):
		BaseGame.load_scene(scene_file)


func want_to_interact(body):
	if (body.name == "Player"):
		change_properties()
		if scene_file:
			BaseGame.front_ui.show_actions_button("interact")
			ready_to_interact = true	
			enter_interact.emit()
		elif dialogue_file && not DialogueStates.is_dialogue_running:
			DialogueStates.start(load(dialogue_file), DialogueStates.DIALOGUE_TYPE.INLINE)
		elif force_complete:
			Quest.quest_complete()
		interact_from = body



func not_want_to_interact(body):
	if (body.name == "Player"):
		if (scene_file || dialogue_file):
			BaseGame.front_ui.hide_actions_button()
			ready_to_interact = false
			exit_interact.emit()
		interact_from = null


