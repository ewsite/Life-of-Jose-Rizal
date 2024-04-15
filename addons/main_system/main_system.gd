@tool
extends EditorPlugin
const _DEFAULT_QUEST_DIRECTORY = "res://Quests"
enum DIALOGUE_TYPE {DEFAULT, ASSESSMENT}
func _enter_tree():
	add_custom_type("Portrait", "Sprite2D", preload("Nodes/Portrait/Portrait.gd"), preload("Assets/Icons/PortraitNodeIcon.png"))
	add_custom_type("NPC", "RigidBody2D", preload("Nodes/NPC/npc.gd"), preload("Assets/Icons/NPCNodeIcon.png"))
	add_custom_type("EntryArea", "Area2D", preload("Nodes/EntryArea/entry_area.gd"), preload("Assets/Icons/NPCNodeIcon.png"))

	add_tool_menu_item("Add normal dialogue to kwan....", _add_dialogue_to_folder.bind(DIALOGUE_TYPE.DEFAULT))
	add_tool_menu_item("Add activity dialogue to kwan....", _add_dialogue_to_folder.bind(DIALOGUE_TYPE.ASSESSMENT))

func _exit_tree():
	remove_custom_type("Portrait")
	remove_custom_type("NPC")
	remove_custom_type("EntryArea")
	
	remove_tool_menu_item("Add dialogue to kwan....")
	remove_tool_menu_item("Add activity dialogue to kwan....")
	
	
func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir()


func _add_dialogue_to_folder(type: DIALOGUE_TYPE):
	var scale: float = get_editor_interface().get_editor_scale()
	var directory_dialog: FileDialog = FileDialog.new()
	var label: Label = Label.new()
	label.text = "Dialogue files will be copied into chosen directory."
	directory_dialog.get_vbox().add_child(label)
	directory_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	directory_dialog.min_size = Vector2(600, 500) * scale
	directory_dialog.set_current_dir(_DEFAULT_QUEST_DIRECTORY)
	directory_dialog.dir_selected.connect(func(path):
		# Copy and edit the scene file
		# Change the script reference to new one
		var template_path: String = get_plugin_path() + "/Templates/NormalDialogue"
		var dialogue_path: String = template_path + "/index.dialogue"
		var script_path: String = template_path + "/index.gd"
		var scene_path: String = template_path + "/index.tscn"

		# Copy the balloon scene file and change the script reference
		var file: FileAccess = FileAccess.open(scene_path, FileAccess.READ)
		var file_contents: String = file.get_as_text().replace(script_path, path + "/index.gd")

		if type == DIALOGUE_TYPE.ASSESSMENT:
			file_contents = file_contents.replace("NormalDialogue", "AssessmentDialogue")
			
		file = FileAccess.open(path + "/index.tscn", FileAccess.WRITE)
		file.store_string(file_contents)
		file.close()

		# Edit the script file
		file = FileAccess.open(script_path, FileAccess.READ)
		file_contents = file.get_as_text()

		if type == DIALOGUE_TYPE.ASSESSMENT:
			file_contents = file_contents.replace("BaseGame.SCENE_TYPE.DIALOGUE", "BaseGame.SCENE_TYPE.ASSESSMENT")

		file = FileAccess.open(path + "/index.gd", FileAccess.WRITE)
		file.store_string(file_contents)
		file.close()
		
		# Copy the dialogue file :)
		file = FileAccess.open(dialogue_path, FileAccess.READ)
		file_contents = file.get_as_text()
		file = FileAccess.open(path + "/index.dialogue", FileAccess.WRITE)
		file.store_string(file_contents)
		file.close()
	
		get_editor_interface().get_resource_filesystem().scan()
		get_editor_interface().get_file_system_dock().call_deferred("navigate_to_path", path + "/index.tscn")
		directory_dialog.queue_free()
	)
	get_editor_interface().get_base_control().add_child(directory_dialog)
	directory_dialog.popup_centered()
	
