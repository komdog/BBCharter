extends Control

func _ready():
	get_viewport().files_dropped.connect(on_files_dropped)

func on_files_dropped(files):
	print(files)
	
	if Save.project_dir != "":
		var dir = DirAccess.open(Save.project_dir)

		for file in files:
			if file.get_extension() == "mp3":
				dir.copy(file, Save.project_dir + "/audio/" + file.get_file())
			elif file.get_extension() == "png":
				dir.copy(file, Save.project_dir + "/audio/" + file.get_file())
		
		Events.emit_signal('project_loaded') # Shortcut

func _input(event):
	
	if Popups.open: return
	
	if event.is_action_pressed("project_open"):
		Global.filedialog.open_project_dialog()	
	if event.is_action_pressed("project_save"):
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
		if Global.project_loaded:
			Popups.reveal(Popups.QUIT)
		else:
			get_tree().quit()
