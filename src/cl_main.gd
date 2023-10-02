extends Control

@onready var file_drop_parser = preload("res://src/rf_drag_and_drop.gd").new()
#@onready var timeline = $Timeline/NoteTimeline


func _ready():
	get_window().min_size = Vector2i(228, 128)
	
	print(DisplayServer.screen_get_size())
	if DisplayServer.screen_get_size() > Vector2i(1920, 1080):
		get_window().size = Vector2i(1920, 1080)
		get_window().position.x -= 320
		get_window().position.y -= 180
	
	get_viewport().files_dropped.connect(on_files_dropped)
	
	for x in Timeline.key_container.get_children():
		if x.get_class() == "Panel":
			x.gui_input.connect(input_test)

func on_files_dropped(files):
	file_drop_parser.get_file_type(files)

func _input(event):
	if Popups.open or Global.lock_timeline: return
	
	if event.is_action_pressed("project_new"):
		Global.file_dialog.new_project_dialog()
	if event.is_action_pressed("project_open"):
		Global.file_dialog.open_project_dialog()
	if event.is_action_pressed("project_reload") and Save.project_dir != "":
		Save.load_project(Save.project_dir)
	if event.is_action_pressed("project_save"):
		Save.save_project()
	if event.is_action_pressed("fullscreen"):
		if get_window().mode == get_window().MODE_WINDOWED:
			get_window().mode = get_window().MODE_FULLSCREEN
		else:
			get_window().mode = get_window().MODE_WINDOWED
	if event.is_action_pressed("open_project_dir"):
		open_uri(Save.project_dir)
	if event.is_action_pressed("open_note_file"):
		open_uri(Save.project_dir + "/config/notes.cfg")
	if event.is_action_pressed("open_keyframes_file"):
		open_uri(Save.project_dir + "/config/keyframes.cfg")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if Global.project_loaded and !Global.project_saved:
			Popups.reveal(Popups.QUIT)
		else:
			get_tree().quit()

func open_uri(uri: String):
	if OS.get_name() == "macOS": uri = "file:" + uri
	OS.shell_open(uri)


func _on_timeline_gui_input(_event): ##doesn't respond to clicks
	#print(event)
	#if event is InputEventMouseButton:
	#	if event.pressed and event.button_mask == MOUSE_BUTTON_MASK_LEFT:

		#if Global.current_tool == Enums.TOOL.SELECT or Global.current_tool == Enums.TOOL.MARQUEE:
			#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				#if Global.current_tool == Enums.TOOL.SELECT:
					#if (get_viewport().get_mouse_position().x < $InputHandler.global_position.x
					#or get_viewport().get_mouse_position().x > $InputHandler.global_position.x + $InputHandler.size.x
					#and clear_clipboard):
						#Clipboard.selected_notes.clear()
						#update_visual()
	pass # Replace with function body.


func _on_note_timeline_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			print("clearing buffer")
			Clipboard.clear_clipboard()
			Events.emit_signal('update_position')
	check_drag(event)
	pass # Replace with function body.

func check_drag(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
				Timeline.key_timeline.mouse_default_cursor_shape = CURSOR_DRAG
				Timeline.note_timeline.mouse_default_cursor_shape = CURSOR_DRAG
				Timeline.scroll = true
		elif (!event.pressed):
				Timeline.key_container.mouse_default_cursor_shape = CURSOR_ARROW
				Timeline.note_timeline.mouse_default_cursor_shape = CURSOR_ARROW
				Timeline.scroll = false
	if event is InputEventMouseMotion:
		if Timeline.scroll:
			Timeline.clamp_seek(event.relative.x * 0.005)

func input_test(event):
	check_drag(event)
	pass
