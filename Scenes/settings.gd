extends CanvasLayer

var scene_type: BaseGame.SCENE_TYPE = BaseGame.SCENE_TYPE.UI
var is_key_changing: bool = false
var target_action: String
@onready var keyboard_input_popup = %KeyboardInputPopup
@onready var animation_player = $AnimationPlayer
@onready var direction_marker_checkbox = %DirectionMarkerCheckbox
@onready var input = %Input

func _ready():
	if GameProps.is_mobile():
		input.queue_free()
	offset.y = 720
	process_mode = Node.PROCESS_MODE_DISABLED
	
func show_panel():
	process_mode = Node.PROCESS_MODE_ALWAYS
	keyboard_input_popup.hide()
	animation_player.play("show")
	await animation_player.animation_finished
	load_input_map()
	load_other()
	
func hide_and_save_panel():
	GameProps.save_game_config()
	animation_player.play("hide")
	await animation_player.animation_finished
	process_mode = Node.PROCESS_MODE_DISABLED

func load_other():
	direction_marker_checkbox.button_pressed = GameProps.show_offscreen_marker
	
func load_input_map():
	if not GameProps.is_mobile():
		for action in InputMap.get_actions():
			if action in GameProps.AVAILABLE_INPUT_MAPS:
				var selected_action = InputMap.action_get_events(action).back() as InputEventKey
				if not has_node("%" + str(action) + "_bind"):
					continue
				# Idunno if it works on other symbols
				var label = get_node("%" + str(action) + "_bind")
				label.text = selected_action.as_text_physical_keycode()
				keyboard_input_popup.hide()

func toggle_fullscreen(toggled_on):
	if (toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _input(event):
	var allow_change: bool = true
	if (is_instance_of(event, InputEventKey) && is_key_changing):
		var new_action_event = event as InputEventKey
		
		# Checks all actions in InputMap
		for key_actions in InputMap.get_actions():
			
			if not allow_change:
				break
	
			if not key_actions in GameProps.AVAILABLE_INPUT_MAPS:
				continue
				
			# Filter only InputEventKey
			var current_action_event = InputMap.action_get_events(key_actions).filter(func(key):
				return is_instance_of(key, InputEventKey)	
			)
			
			# Check InputEventKeys inside of an action in InputMap
			for c_event in current_action_event:
				if not allow_change:
					break
				print(new_action_event.unicode)
				if c_event.physical_keycode == new_action_event.physical_keycode:
					print(key_actions)
					allow_change = false
					
		if allow_change:
			InputMap.action_erase_events(target_action)
			InputMap.action_add_event(target_action, event)	
					
		is_key_changing = false
		target_action = ""
		load_input_map()


func change_input_map(action: String):
	is_key_changing = true
	target_action = action
	keyboard_input_popup.show()


func open_cheats():
	var open_cheats_event = InputEventAction.new()
	open_cheats_event.action = "open_cheats"
	open_cheats_event.pressed = true
	Input.parse_input_event(open_cheats_event)


func toggle_offscreen_marker(toggled_on):
	GameProps.show_offscreen_marker = toggled_on
	print(GameProps.show_offscreen_marker)
