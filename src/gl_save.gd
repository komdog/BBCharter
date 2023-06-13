extends Node

var project_dir: String

var asset: Dictionary
var keyframes: Dictionary
var meta: Dictionary
var notes: Dictionary
var settings: Dictionary

# Default parameters
var song_offset_default = 0.0
var modifier_default = [{"bpm": 128.0, "timestamp": 0}]

func save_project() -> void:
	#Save keyframes
	keyframes['loops'].sort_custom(func(a,b): return a['timestamp'] < b['timestamp'])
	if save_cfg('keyframes.cfg', keyframes) == FAILED: return print('Could not save keyframes.cfg')
	
	#Save Notes
	notes['charts'][Global.difficulty_index]['notes'] = Global.current_chart # Move chart to save cache
	notes['charts'].sort_custom(func(a,b): return a['rating'] < b['rating'])
	if save_cfg('notes.cfg', notes) == FAILED: return print('Could not save notes.cfg')
	
	Global.project_saved = true
	Events.emit_signal('notify', 'Saved Project', meta['level_name'], project_dir + "/thumb.png")
	
	
func save_cfg(file_name: String, new_data) -> int:
	var path = project_dir + "/config/" + file_name
	var config = ConfigFile.new()
	config.set_value('main', 'data', new_data)
	if config.save(path) == OK:
		return OK
	else:
		return FAILED
		
		
func valid_project():
	if load_cfg('asset.cfg') == {}:
		print("Could not load 'asset.cfg'")
		return false
	if load_cfg('keyframes.cfg') == {}:
		print("Could not load 'keyframes.cfg'")
		return false
	if load_cfg('meta.cfg') == {}:
		print("Could not load 'meta.cfg'")
		return false
	if load_cfg('settings.cfg') == {}:
		print("Could not load 'settings.cfg'")
		return false
	if load_cfg('notes.cfg') == {}:
		print("Could not load 'notes.cfg'")
		return false
	if !FileAccess.file_exists(project_dir + "/audio/" + load_cfg('asset.cfg').get('song_path', "")):
		print("Could not load '%s'" % load_cfg('asset.cfg').get('song_path', "song_path"))
		return false
	return true


func load_project(file_path):
	
	var old_project_dir = project_dir
	project_dir = file_path
	
	if valid_project():
		# Order Matters
		Global.project_loaded=false
		Timeline.clear_timeline()
		Timeline.reset()
		notes = {}

		asset = load_cfg('asset.cfg')
		keyframes = load_cfg('keyframes.cfg')
		meta = load_cfg('meta.cfg')
		settings = load_cfg('settings.cfg')

		await get_tree().process_frame
		await get_tree().physics_frame
		
		Assets.lib.clear()
		Assets.load_images()
		Assets.load_audio()

		load_chart()
		load_keyframes()
		load_song()	
	
		Events.emit_signal('notify', 'Project Loaded', meta['level_name'], project_dir + "/thumb.png")
		Events.emit_signal('project_loaded')
		Global.project_saved=true
		Global.project_loaded=true
	else:
		Events.emit_signal('notify', 'Error loading project', 'Invalid level: ' + project_dir.get_file(), "")
		project_dir = old_project_dir


func load_cfg(file_name: String) -> Dictionary:
	var path = project_dir + "/config/" + file_name
	var config = ConfigFile.new()
	if config.load(path) == OK:
		return config.get_value('main', 'data', {})
	else:
		print("Could not open %s" % path)
		return {}
		

		
func load_keyframes():
	Global.bpm = Save.keyframes.get('modifiers', modifier_default)[0]['bpm']
	Global.offset = Save.settings.get('song_offset', song_offset_default)
	Global.beat_length_msec = ( 60.0 / Global.bpm )
	
func load_song():
	var path = project_dir + "/audio/" + asset.get('song_path', "")
	Global.music.stream = Global.load_mp3(path)
	Global.song_length = Global.music.stream.get_length()
	Global.song_beats_per_second = float(60.0/Global.bpm)
	Global.song_beats_total = int(Global.song_length / Global.song_beats_per_second)
	Events.emit_signal('song_loaded')

func load_chart(difficulty_index: int = 0) -> int:
	if notes.is_empty():
		notes = load_cfg('notes.cfg')
		print('Loading from config')
	else:
		notes['charts'][Global.difficulty_index]['notes'] = Global.current_chart.duplicate(true)
		print('Storing previous chart')
	Timeline.clear_notes_only()
	if notes != {}:
		if notes['charts'].size() < 1:
			create_difficulty()
			save_cfg('notes.cfg', notes)
		Global.current_chart = notes['charts'][difficulty_index]['notes'].duplicate(true)
		Global.difficulty_index = difficulty_index
		Events.emit_signal('chart_loaded')
		return OK
	else:
		return FAILED

func create_difficulty(diffcuilty_name: String = "Virgin", rating: int = 0, chart: Array = []):
	print("Creating Difficuilty %s" % diffcuilty_name)
	var new_difficulty: Dictionary = {
		'name': diffcuilty_name,
		'rating': rating,
		'notes': chart
	}
	notes['charts'].append(new_difficulty) 
	
