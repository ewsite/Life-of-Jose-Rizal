extends CharacterBody2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d = $Camera2D
@onready var path_follow_c: TextureRect = %PathFollowC
@onready var path_distance_left_label = %PathDistanceLeftLabel

const normal_speed = 150
const run_speed = 300

var is_zoom: bool
var SPEED: int


func _ready():
	path_follow_c.hide()
	var current_map_name = GameStats.current_map_name
	if GameStats.is_save_map_position_exists(current_map_name):
		position = GameStats.get_player_position(current_map_name)
	else:
		print("Map" + current_map_name + " doesn't exists. Creating....")
		GameStats.update_player_position(current_map_name, position)

func _unhandled_input(event):
	pass
	#is_zoom = event.is_action_pressed("player_zoom")
	#camera_2d.zoom = Vector2(1, 1) if is_zoom else Vector2(2.5, 2.5)


func percent_range(wrange: float, start: float, end: float) -> float:
	return (wrange - start) / (end - start)


func _physics_process(_delta):
	var current_map_name = GameStats.current_map_name
	velocity = Vector2.ZERO
	

	if Input.is_action_pressed("player_walk_left"):
		animated_sprite_2d.play("walk_left")
		velocity.x = -1 * SPEED
	elif Input.is_action_pressed("player_walk_right"):
		animated_sprite_2d.play("walk_right")
		velocity.x = SPEED
	elif Input.is_action_pressed("player_walk_up"):
		animated_sprite_2d.play("walk_up")
		velocity.y = -1 * SPEED
	elif Input.is_action_pressed("player_walk_down"):
		animated_sprite_2d.play("walk_down")
		velocity.y = SPEED
	else:
		animated_sprite_2d.play("idle")

	if Input.is_action_pressed("player_run") && not velocity == Vector2.ZERO:
		animated_sprite_2d.speed_scale = 2.0
		SPEED = run_speed
	else:
		animated_sprite_2d.speed_scale = 1.0
		SPEED = normal_speed

	move_and_slide()
	GameStats.update_player_position(current_map_name, position)



#func stop_path_follow():
	#path_follow_c.hide()
