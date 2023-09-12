extends FileDialog

var create:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "macOS":
		var dir = OS.get_executable_path().get_basename()
		if dir.get_slice("/", dir.get_slice_count("/")-1) != "Godot":
			var app = dir.get_slice("/", dir.get_slice_count("/")-4)
			dir = OS.get_executable_path().get_base_dir().trim_suffix("/" + app + "/Contents/MacOS")
			current_dir = dir
	else:
		if !OS.is_debug_build():
			current_dir = OS.get_executable_path().get_base_dir()
	
	Global.filedialog = self

func open_project_dialog():
	print('Opening New Project...')
	title = "Select Project Directory"
	create = false
	popup()

func new_project_dialog():
	print('Creating New Project...')
	title = "Create Project Directory"
	create = true
	popup()

func _on_dir_selected(path: String):
	if create:
		var dir = DirAccess.open(path)
		if !dir.dir_exists(path + "/audio"):
			dir.make_dir("audio")
		if !dir.dir_exists(path + "/images"):
			dir.make_dir("images")
		if !dir.dir_exists(path + "/config"):
			dir.make_dir("config")
		
		var config = ConfigFile.new()
		if !dir.file_exists(path + "/config/asset.cfg"):
			config.set_value("main", "data", {
				"song_path":"base_jam.mp3",
				"horny_mode_sound":"",
				"final_video":"",
				"final_audio":""
			})
			await get_tree().physics_frame
			config.save(path + "/config/asset.cfg")
		
		if !dir.file_exists(path + "/config/keyframes.cfg"):
			config.set_value("main", "data", {
				"background": [],
				"effects": [],
				"loops": [],
				"modifiers": [{
					"bpm": 128.0,
					"timestamp": 0
				}],
				"sound_loop": [],
				"sound_oneshot": [],
				"shutter": [],
				"voice_bank": []
			})
			await get_tree().physics_frame
			config.save(path + "/config/keyframes.cfg")
		
		if !dir.file_exists(path + "/config/meta.cfg"):
			config.set_value("main", "data", {
				"character": "Your Mom",
				"color": [1.00000, 1.00000, 1.00000],
				"level_index":0,
				"level_name":"Base"
			})
			await get_tree().physics_frame
			config.save(path + "/config/meta.cfg")
		
		if !dir.file_exists(path + "/config/notes.cfg"):
			config.set_value("main", "data", {"charts": []})
			config.save(path + "/config/notes.cfg")
		
		if !dir.file_exists(path + "/config/settings.cfg"):
			config.set_value("main", "data", {
				"song_offset":0.0,
				"background_type":0
			})
			await get_tree().physics_frame
			config.save(path + "/config/settings.cfg")
		create = false
	
	Save.load_project(path)
