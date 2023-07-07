extends Node

var filedialog: FileDialog
var music: AudioStreamPlayer

# Chart Data
var current_chart: Array = []

# Chart Settings
var bpm: float
var global_bpm: float
var bpm_index: int

var offset: float
var bpm_offset: float
var beat_offset: float

var note_speed: float = 200
var difficulty_index: int

# Realtime Info
var song_pos: float
var song_length: float
var mouse_pos: float

var song_beats_total: int
var song_seconds_per_beat: float
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

func get_timestamp_snapped() -> float:
	return snappedf(song_pos - bpm_offset, (song_seconds_per_beat) / snapping_factor) + bpm_offset

func get_mouse_timestamp() -> float:
	var time = ((song_pos * note_speed) - mouse_pos)/note_speed
	if time < -offset: time = -offset
	elif time > song_length - offset: time = song_length - offset
	return time

func get_mouse_timestamp_snapped() -> float:
	var time = snappedf(get_mouse_timestamp() - bpm_offset, (song_seconds_per_beat) / snapping_factor) + bpm_offset
	if time < -offset: time = -offset
	elif time > song_length - offset: time = song_length - offset
	return time

func clear_children(parent: Node):
	print("Cleaning %s's children" % parent.name)
	for child in parent.get_children():
		child.queue_free()

func reload_bpm(idx: int = 0):
	if idx > Save.keyframes['modifiers'].size()-1: idx = Save.keyframes['modifiers'].size()-1
	if Save.keyframes['modifiers'].size() <= 1: beat_offset = 0
	bpm = Save.keyframes.get('modifiers', Save.modifier_default)[idx]['bpm']
	
	beat_length_msec = 60.0/bpm
	song_seconds_per_beat = float(60.0/bpm)
	song_beats_total = int((song_length - offset - bpm_offset - beat_offset) / song_seconds_per_beat)
	
	if Global.project_loaded:
		Events.emit_signal('update_notespeed')
		Events.emit_signal('update_bpm')
