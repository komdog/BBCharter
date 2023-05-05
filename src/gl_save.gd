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
	if Global.current_chart.is_empty(): return print('No Chart To Export')
	
	#Save keyframes
	keyframes['loops'].sort_custom(func(a,b): return a['timestamp'] < b['timestamp'])
	if save_cfg('keyframes.cfg', keyframes) == FAILED: return print('Could not save keyframes.cfg')
	
	#Save Notes
	notes['charts'][Global.difficulty_index]['notes'] = Global.current_chart # Move chart to save cache
	notes['charts'].sort_custom(func(a,b): return a['rating'] < b['rating'])
	if save_cfg('notes.cfg', notes) == FAILED: return print('Could not save notes.cfg')
	
	Events.emit_signal('notify', 'Saved Project', meta['level_name'], project_dir + "/thumb.png")
	
	
func save_cfg(file_name: String, new_data) -> int:
	var path = project_dir + "/config/" + file_name
	var config = ConfigFile.new()
	config.set_value('main', 'data', new_data)
	if config.save(path) == OK:
		return OK
	else:
		return FAILED
		
		
func load_project(file_path):
	
	project_dir = file_path
	
	Timeline.clear_timeline()
	
	asset = load_cfg('asset.cfg')
	await get_tree().process_frame
	
	keyframes = load_cfg('keyframes.cfg')
	await get_tree().process_frame
	
	meta = load_cfg('meta.cfg')
	await get_tree().process_frame
	
	settings = load_cfg('settings.cfg')
	await get_tree().process_frame
	
	Assets.lib.clear()
	Assets.load_images()
	Assets.load_audio()
	
	load_chart()
	
	# Order Matters
	load_keyframes()
	load_song()	
	
	
	Events.emit_signal('notify', 'Project Loaded', meta['level_name'], project_dir + "/thumb.png")
	Events.emit_signal('project_loaded')
	Global.project_loaded=true


func load_cfg(file_name: String) -> Dictionary:
	var path = project_dir + "/config/" + file_name
	var config = ConfigFile.new()
	if config.load(path) == OK:
		return config.get_value('main', 'data', null)
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
	Timeline.clear_notes_only()
	notes = load_cfg('notes.cfg')
	if notes.is_empty(): return FAILED
	if notes['charts'].size() < 1: create_difficulty()
	Global.current_chart = notes['charts'][difficulty_index]['notes'].duplicate(true)
	Global.difficulty_index = difficulty_index
	Events.emit_signal('chart_loaded')
	return OK

func create_difficulty(diffcuilty_name: String = "Normal", rating: int = 1, chart: Array = []):
	print("Creating Difficuilty %s" % diffcuilty_name)
	var new_difficulty: Dictionary = {
		'name': diffcuilty_name,
		'rating': rating,
		'notes': chart
	}
	notes['charts'].append(new_difficulty) 
	
func delete_difficulty() -> void:
	Global.current_chart.clear()
	#Save Notes
	notes['charts'].remove_at(Global.difficulty_index)
	notes['charts'].sort_custom(func(a,b): return a['rating'] < b['rating'])
	if save_cfg('notes.cfg', notes) == FAILED: return print('Could not save notes.cfg')
	
	Save.load_project(Save.project_dir)
	
	
