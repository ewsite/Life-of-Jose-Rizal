# Next feature to be added:
# ---------------------------------------------------------
# AnimatedNPCBody
#

@tool
class_name NPC extends RigidBody2D

@export_category("NPC Properties")
@export_group("NPC Information")
@export var character_name: String = "Rodel"
@export var character_description: String
@export var is_enemy: bool
@export var used_for_tutorial: bool
@export_group("NPC Transform")
@export_range(0, 200, 1) var npc_scale: int = 100
@export var flip_horizontally: bool = false
@export var flip_vertically: bool = false
@export_group("Appearance")
@export var sprite_texture: Texture2D = preload("NPCPlaceholder.png")
@export var animated_npc_body: AnimatedSprite2D
@export_group("When Interact Happens?")
@export var is_inline_scene: bool
@export_file("*.tscn") var scene_file: String
@export_file("*.dialogue") var dialogue_file: String
@export_group("Others")
@export var player_node: Node2D

@onready var npc_collision_area: CollisionShape2D = $NPCCollisionArea
@onready var interaction_collision_area: CollisionShape2D = $"InteractionArea/InteractionCollisionArea"
@onready var npc_body: Sprite2D = $NPCBody
@onready var interaction_area: Area2D = $"InteractionArea"
@onready var npc_offscreen_marker: Node2D = $"NPCOffScreenMarker"
@onready var npc_nametag: Node2D = $"NPCNametag"

var npc_quest_indicator_texture: Texture2D = preload("NPCQuestIndicator.png")
# Available Signals
signal enter_interact
signal exit_interact

var ready_to_interact = false
var interact_from
var size: Vector2:
	get:
		if not sprite_texture:
			return Vector2.ZERO
		var crack_scale = float(npc_scale) * 0.01
		var sprite_size = sprite_texture.get_size()
		return Vector2(sprite_size.x * crack_scale, sprite_size.y * crack_scale)
		
const INTERACTION_AREA_SCALE: float = 4.0


func _enter_tree():

	if get_child_count(true):
		return

	var dz_interaction_area: Area2D = Area2D.new()
	var dz_offscreen_marker: Node2D = preload("../../Microcomponents/OffScreenMarker/OffScreenMarker.tscn").instantiate()
	var dz_npc_collision_area: CollisionShape2D = CollisionShape2D.new()
	var dz_interaction_collision_area: CollisionShape2D = CollisionShape2D.new()
	var dz_nametag: Node2D = preload("../../Microcomponents/Nametag/Nametag.tscn").instantiate()
	var dz_nca_shape2d: RectangleShape2D = RectangleShape2D.new()
	var dz_ica_shape2d: RectangleShape2D = RectangleShape2D.new()

	var dz_npc_body: Sprite2D = Sprite2D.new()
	# Changing name
	dz_npc_body.name = "NPCBody"
	dz_npc_collision_area.name = "NPCCollisionArea"
	dz_interaction_area.name = "InteractionArea"
	dz_interaction_collision_area.name = "InteractionCollisionArea"
	dz_offscreen_marker.name = "NPCOffScreenMarker"
	dz_nametag.name = "NPCNametag"
	# Change props
	gravity_scale = 0
	dz_npc_body.texture = sprite_texture
	dz_offscreen_marker.target_node = player_node
	dz_offscreen_marker.root_node = self
	# Add boundaries to colliders
	dz_interaction_collision_area.shape = dz_ica_shape2d
	dz_npc_collision_area.shape = dz_nca_shape2d
	dz_interaction_area.body_entered.connect(want_to_interact)
	dz_interaction_area.body_exited.connect(not_want_to_interact)
	# Add child to subchild
	dz_interaction_area.add_child(dz_interaction_collision_area)
	
	# Add child to the main node
	add_child(dz_npc_collision_area)
	add_child(dz_npc_body)
	add_child(dz_interaction_area)
	add_child(dz_nametag)
	add_child(dz_offscreen_marker)

func _ready():
	change_properties()
		
func _process(_delta):
	await get_tree().physics_frame
	npc_offscreen_marker.enabled = true if (scene_file || dialogue_file) && player_node else false	
	if Engine.is_editor_hint():
		change_properties()
	
	
func change_properties():
	var crack_scale = float(npc_scale) * 0.01

	if not npc_body:
		return
		
	if sprite_texture:
		npc_body.texture = sprite_texture
		npc_body.set_scale(Vector2(crack_scale, crack_scale))
		npc_body.flip_h = flip_horizontally
		npc_body.flip_v = flip_vertically
		npc_body.show()
	else:
		return
		
	npc_nametag.label_name = character_name
	#npc_nametag.is_quest = true if scene_file else false
	npc_nametag.position.y = -(size.y / 2)
	# Set size of the collision based on the size of custom texture.
	npc_collision_area.shape.set_size(Vector2(size.x, size.y * 0.2))
	# Set collision size based on the size of custom texture + 3x more size
	# for more allowance ehe
	interaction_collision_area.shape.set_size(Vector2(size.x * INTERACTION_AREA_SCALE, size.y * INTERACTION_AREA_SCALE))

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
		interact_from = body
		npc_body.flip_h = true


func not_want_to_interact(body):
	if (body.name == "Player"):
		if (scene_file || used_for_tutorial):
			BaseGame.front_ui.hide_actions_button()
			ready_to_interact = false
			exit_interact.emit()
		interact_from = null
		npc_body.flip_h = false

