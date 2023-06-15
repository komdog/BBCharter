extends Node

var filedialog: FileDialog
var music: AudioStreamPlayer

# Chart Data
var current_chart: Array = []

# Chart Settings
var bpm: float
var offset: float
var note_speed: float = 200
var difficulty_index: int
var difficulty_max: int = 10

# Realtime Info
var song_pos: float
var song_length: float
var song_beats_total: int
var song_beats_per_second: float
var beat_length_msec: float

# Editor Settings
var note_culling_bounds: Vector2 = Vector2(0, 1920)
var snapping_ratios = [1,2,4,8]
var snapping_factor = 2
var snapping_allowed = true
var project_loaded = false
var project_saved = false
var current_tool = Enums.TOOL.SELECT



var note_colors: PackedColorArray = [
		Color(0.1,0.55,0.78,1), #Blue
		Color(0.93,0.47,0.05,1), #Orange
		Color(0.78,0.17,0.09,1), #Red
		Color(0.67,0.17,0.39,1), #Purple
	]
	
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
	return snappedf(song_pos, (song_beats_per_second / snapping_factor))

func get_synced_song_pos() -> float:
	return song_pos
	
func clear_children(parent: Node):
	print("Cleaning %s's children" % parent.name)
	for child in parent.get_children():
		child.queue_free()

func find_lowest_factor(n: int) -> int:
	# Finds the lowest factor of a given number n
	var i = 2  # start with 2 as the smallest possible integer greater than 1
	while i <= n:
		if n % i == 0:  # check if i is a factor of n
			return i  # return the lowest factor
		i += 1  # increment i to check the next integer
	return n  # if no factor is found, n is a prime number
