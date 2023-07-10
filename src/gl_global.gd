extends Node

var filedialog: FileDialog
var music: AudioStreamPlayer

# Chart Data
var current_chart: Array = []

# Chart Settings
var bpms: Array = []
var bpm_timestamps: Array = []
var bpm_beatstamps: Array = []

var offset: float

var note_speed: float = 200
var difficulty_index: int

# Whether or not notes need to be recalculated before saving
var mods_need_reapply: bool

# Realtime Info
var song_pos: float
var song_length: float
var mouse_pos: float

var song_beats_total: int
var zoom_factor: float
var beat_length_msec: float

# Editor Settings
var note_culling_bounds: Vector2 = Vector2(0, 1920)
var snapping_ratios = [1,2,3,4,6,8]
var snapping_factor = 2
var snapping_allowed = true

var project_loaded = false
var project_saved = false

var current_tool = Enums.TOOL.SELECT
var replacing_allowed = false

var lock_timeline = false
var reloading_bpm = false

var note_colors: PackedColorArray = [
		Color(0.1,0.55,0.78,1), #Blue
		Color(0.93,0.47,0.05,1), #Orange
		Color(0.78,0.17,0.09,1), #Red
		Color(0.67,0.17,0.39,1), #Purple
	]

func _process(_delta):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	or Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
	or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		mouse_pos = get_window().get_mouse_position().x - 960

func load_mp3(path) -> AudioStreamMP3:
	var song_file = FileAccess.open(path, FileAccess.READ)
	var bytes = song_file.get_buffer(song_file.get_length())
	var mp3_steam = AudioStreamMP3.new()
	mp3_steam.data = bytes
	song_file.close()
	print('Loaded %s' % path)
	return mp3_steam

func load_texture(path) -> ImageTexture:
	if !FileAccess.file_exists(path): return
	var tex = ImageTexture.create_from_image(Image.load_from_file(path))
	return tex

func get_timestamp_snapped(pos: float = song_pos) -> float:
	return get_time_at_beat(snappedf(get_beat_at_time(pos), 1.0/snapping_factor))

func get_mouse_timestamp() -> float:
	var time = ((song_pos * note_speed) - mouse_pos)/note_speed
	if time < -offset: time = -offset
	elif time > song_length - offset: time = song_length - offset
	return time

func get_mouse_timestamp_snapped() -> float:
	var time = get_timestamp_snapped(((song_pos * note_speed) - mouse_pos)/note_speed)
	if time < -offset: time = -offset
	elif time > song_length - offset: time = song_length - offset
	return time

func get_current_bpm_timestamp() -> float:
	var prevEntry = 0.0
	for entry in bpm_timestamps:
		if entry > song_pos:
			return prevEntry
		prevEntry = entry
	return bpm_timestamps[-1]

func get_current_bpm() -> float:
	var prevEntry = 0.0
	for i in bpm_timestamps.size():
		if bpm_timestamps[i] > song_pos:
			return prevEntry
		prevEntry = bpms[i]
	return bpms[-1]

func clear_children(parent: Node):
	print("Cleaning %s's children" % parent.name)
	for child in parent.get_children():
		child.queue_free()

func reload_bpm():
	var cumulativeBeats = 0.0
	var prevTimestamp = 0.0
	var prevBpm = 0.0
	if !bpms.is_empty():
		bpms.clear()
		bpm_timestamps.clear()
		bpm_beatstamps.clear()
	for mod in Save.keyframes.get('modifiers', Save.modifier_default):
		bpms.append(mod['bpm'])
		bpm_timestamps.append(mod['timestamp'])
		cumulativeBeats += (mod['timestamp'] - prevTimestamp) * (prevBpm / 60)
		bpm_beatstamps.append(cumulativeBeats)
		prevTimestamp = mod['timestamp']
		prevBpm = mod['bpm']
	song_beats_total = ceil(get_beat_at_time(song_length - offset))
	
	mods_need_reapply = true
	
	if project_loaded:
		Events.emit_signal('update_notespeed')
		Events.emit_signal('update_bpm')

func get_beat_at_time(time: float) -> float:
	var idx = 1
	while idx < bpm_timestamps.size():
		if bpm_timestamps[idx] > time:
			break
		idx += 1
	return bpm_beatstamps[idx-1] + ((time - bpm_timestamps[idx-1]) * (bpms[idx-1] / 60))

func get_time_at_beat(beat: float) -> float:
	var idx = 1
	while idx < bpm_beatstamps.size():
		if bpm_beatstamps[idx] > beat:
			break
		idx += 1
	return bpm_timestamps[idx-1] + ((beat - bpm_beatstamps[idx-1]) * (1 / (bpms[idx-1] / 60.0)))
