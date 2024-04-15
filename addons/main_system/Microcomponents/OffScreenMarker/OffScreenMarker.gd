@tool
extends Node2D

@export var target_node: Node2D
@export var root_node: Node2D
@export var enabled: bool = true
@onready var indicator: Sprite2D = $Indicator
@onready var indicator_item = $Indicator/IndicatorItem
@onready var distance_left_label = $Indicator/IndicatorItem/DistanceLeftLabel

var indicator_texture: CompressedTexture2D = preload("Indicator.png")
var target_position: Vector2


func _ready():
	pass
	
func _process(_delta):
	if not enabled || not target_node:
		hide()
	else:
		show()
func _physics_process(_delta):
	if not Engine.is_editor_hint():
		var canvas_coords: Transform2D = get_canvas_transform()
		var tl = -canvas_coords.origin / canvas_coords.get_scale()
		var size = get_viewport_rect().size / canvas_coords.get_scale()
		
		if target_node:
			target_position = target_node.position
		else:
			target_position = Vector2.ZERO
		set_marker_position(Rect2(tl, size))
		set_marker_rotation(Rect2(tl, size))
	set_distance_left()
	
func set_marker_position(bounds: Rect2):
	
	if target_position == Vector2.ZERO:
		return

		
	var displacement = global_position - target_position
	var length
	
	
	# Radian Points
	var tl = (bounds.position - target_position).angle()
	var tr = (Vector2(bounds.end.x, bounds.position.y) - target_position).angle()
	var bl = (Vector2(bounds.position.x, bounds.end.y) - target_position).angle()
	var br = (bounds.end - target_position).angle()

	if  (displacement.angle() > tl && displacement.angle() < tr) || displacement.angle() < bl && displacement.angle() > br:
		var y_length = clamp(displacement.y, bounds.position.y - target_position.y, bounds.end.y - target_position.y)
		var angle = displacement.angle() - PI / 2
		if cos(angle) != 0:
			length = y_length / cos(angle)
		else:
			length = y_length
	else:
		var x_length = clamp(displacement.x, bounds.position.x - target_position.x, bounds.end.x - target_position.x)
		var angle = displacement.angle()
		if cos(angle) != 0:
			length = x_length / cos(angle)
		else:
			length = x_length
			
	if bounds.has_point(global_position):
		indicator.global_position = Vector2(root_node.global_position.x, root_node.global_position.y - root_node.size.y)
	else:	
		indicator.global_position = Vector2(length * cos(displacement.angle()), length * sin(displacement.angle())) + target_position


func set_marker_rotation(bounds):
	if not Engine.is_editor_hint():
		var angle: float = indicator.global_position.angle_to_point(global_position)
		if bounds.has_point(global_position):
			indicator.rotation_degrees = 90
		else:
			indicator.global_rotation = angle

		indicator_item.rotation = -indicator.rotation
			
func set_distance_left():
	if Engine.is_editor_hint():
		distance_left_label.text = "Ready"
		indicator.rotation_degrees = 90
		indicator_item.rotation = -indicator.rotation
	else:
		if target_node && root_node:
			var distance_left: float = root_node.global_position.distance_to(target_node.global_position)
			distance_left_label.text = str(int(abs(distance_left / 32))) + "m"
		else:
			distance_left_label.text = "0m"
