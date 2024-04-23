extends CanvasLayer

@onready var interact_button = %InteractButton
@onready var talk_button = %TalkButton
@onready var enter_button = %EnterButton
@onready var exit_button = %ExitButton
@onready var touch_button = %TouchButton
@onready var quest_title_label = %QuestTitleLabel
@onready var quest_description_label = %QuestDescriptionLabel
@onready var heart_indicator_panel = %HeartIndicatorPanel

@onready var actions_ui = %ActionsUI
@onready var upper_ui = %UpperUI
@onready var bottom_controllers = %BottomControllers
@onready var pause_button = %PauseButton

@onready var action_lists_container = %ActionListsContainer
@onready var quest_list_container = %QuestListContainer

@onready var quest_complete_popup = %QuestCompletePopup
@onready var quest_complete_duration = %QuestCompleteDuration
@onready var quest_complete_animation = %QuestCompleteAnimation


func reset():
	
	# Panels and Indicators
	actions_ui.show()
	pause_button.show()
	heart_indicator_panel.show()
	heart_indicator_panel.reset()
	bottom_controllers.show()
	upper_ui.show()
	hide_actions_button()
	
func _ready():
	Quest.quest_completed.connect(show_quest_complete_popup)
	quest_complete_popup.position.y = -160

func _process(delta):
	if quest_description_label.text == "":
		quest_list_container.hide()
	else:
		quest_list_container.show()
		
func activate_actions_ui():
	actions_ui.show()

func activate_pause_button():
	pause_button.show()
	
func deactivate_pause_button():
	pause_button.hide()
	
func deactivate_actions_ui():
	actions_ui.hide()	
	
func show_quest_complete_popup(need_popup: bool):
	if need_popup:
		await get_tree().create_timer(0.5).timeout
		quest_complete_duration.start()
		quest_complete_animation.play("show")
		await quest_complete_duration.timeout
		quest_complete_animation.play("hide")

func activate_heart_indicator_panel():
	heart_indicator_panel.show()

func deactivate_heart_indicator_panel():
	heart_indicator_panel.hide()

func hide_actions_button():
	var buttons: Array[Node] = action_lists_container.get_children(true)
	for button in buttons:
		button.hide()

func show_actions_button(action: String):
	match action:
		"interact":
			interact_button.show()
		"talk":
			talk_button.show()
		"enter":
			talk_button.show()
		"exit":
			exit_button.show()
		"touch":
			touch_button.show()
			

func trigger_pause_menu():
	var pause_event = InputEventAction.new()
	pause_event.action = "ui_cancel"
	pause_event.pressed = true
	Input.parse_input_event(pause_event)

func show_panel():
	show()
func hide_panel():
	reset()
	hide()
func _on_visibility_changed():
	if visible:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
