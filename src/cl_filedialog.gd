extends FileDialog

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.filedialog = self
	
func open_project_dialog():
	
	print('Opening New Project...')
	
	# DELETE THIS ON RELEASE
	Global.filedialog.current_dir = "D:/Mega/Projects/BunFan/Games/beat_banger/_project/data/act1/"
	
	Global.filedialog.title = "Select Project Folder"
	Global.filedialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	Global.filedialog.popup()
	
	

	
func _on_dir_selected(path: String):
	Save.load_project(path)
