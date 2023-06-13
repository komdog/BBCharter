extends Control

@onready var file_drop_parser = preload("res://src/rf_drag_and_drop.gd").new()

func _ready():
	get_viewport().files_dropped.connect(on_files_dropped)

func on_files_dropped(files):
	file_drop_parser.get_file_type(files)


func _input(event):
	
	if Popups.open: return
	
	if event.is_action_pressed("project_new") and event.is_command_or_control_pressed():
		Global.filedialog.new_project_dialog()
	if event.is_action_pressed("project_open") and event.is_command_or_control_pressed():
		Global.filedialog.open_project_dialog()
	if event.is_action_pressed("project_reload") and event.is_command_or_control_pressed() and Save.project_dir != "":
		Save.load_project(Save.project_dir)
	if event.is_action_pressed("project_save") and event.is_command_or_control_pressed():
		Save.save_project()
	if event.is_action_pressed("open_project_dir"):
		if OS.get_name() == "macOS":
			OS.shell_open("file:" + Save.project_dir)
		else:
			OS.shell_open(Save.project_dir)
	if event.is_action_pressed("open_note_file"):
		if OS.get_name() == "macOS":
			OS.shell_open("file:" + Save.project_dir + "/config/notes.cfg")
		else:
			OS.shell_open(Save.project_dir + "/config/notes.cfg")
	if event.is_action_pressed("open_keyframes_file"):
		if OS.get_name() == "macOS":
			OS.shell_open("file:" + Save.project_dir + "/config/keyframes.cfg")
		else:
			OS.shell_open(Save.project_dir + "/config/keyframes.cfg")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if Global.project_loaded and !Global.project_saved:
			Popups.reveal(Popups.QUIT)
		else:
			get_tree().quit()
