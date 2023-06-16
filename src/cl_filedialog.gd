extends FileDialog

var create:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "macOS":
		var dir = OS.get_executable_path().get_basename()
		print(dir)
		if dir.get_slice("/", dir.get_slice_count("/")-1) != "Godot":
			var app = dir.get_slice("/", dir.get_slice_count("/")-4)
			print(app)
			dir = OS.get_executable_path().get_base_dir().trim_suffix("/" + app + "/Contents/MacOS")
			current_dir = dir
			print(current_dir)
	else:
		if !OS.is_debug_build():
			current_dir = OS.get_executable_path().get_base_dir()
	
	Global.filedialog = self

func open_project_dialog():
	print('Opening New Project...')
	create = false
	
	title = "Select Project Folder"
	file_mode = FileDialog.FILE_MODE_OPEN_DIR
	popup()

func new_project_dialog():
	print('Creating New Project...')
	create = true
	
	title = "Select Folder"
	file_mode = FileDialog.FILE_MODE_OPEN_DIR
	popup()

func _on_dir_selected(path: String):
	if create:
		var dir = DirAccess.open(path)
		var res = ProjectSettings.globalize_path("res://assets/base/")
		if !dir.dir_exists(path + "/audio"):
			dir.make_dir("audio")
			dir.copy(res + "base_jam.mp3", path + "/audio/base_jam.mp3")
			dir.copy(res + "sfx_squish.mp3", path + "/audio/sfx_squish.mp3")
			dir.copy(res + "sfx_shutter.mp3", path + "/audio/sfx_shutter.mp3")
		if !dir.dir_exists(path + "/images"):
			dir.make_dir("images")
		if !dir.dir_exists(path + "/config"):
			dir.make_dir("config")
			dir.copy(res + "asset.cfg", path + "/config/asset.cfg")
			dir.copy(res + "meta.cfg", path + "/config/meta.cfg")
			dir.copy(res + "settings.cfg", path + "/config/settings.cfg")

		var config = ConfigFile.new()
		if !dir.file_exists(path + "/config/keyframes.cfg"):
			config.set_value("main", "data", {
				"background": [],
				"effects": [],
				"loops": [],
				"modifiers": [{
					"bpm": 128.0,
					"timestamp": 0
				}],
				"sound_loop": [{
					"path": "sfx_squish.mp3",
					"timestamp": 0
				}],
				"sound_oneshot": [],
				"shutter": [],
				"voice_bank": []
			})
			config.save(path + "/config/keyframes.cfg")
		if !dir.file_exists(path + "/config/notes.cfg"):
			config.set_value("main", "data", {"charts": []})
			config.save(path + "/config/notes.cfg")
		
		create = false
	
	Save.load_project(path)
