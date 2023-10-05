extends AudioStreamPlayer

var sound_index: int
var last_sound_index: int

func _ready():
	Events.song_loaded.connect(_on_song_loaded)

func _on_song_loaded():
	sound_index = 0; last_sound_index = 0

func _process(_delta):
	if Save.keyframes.has('sound_oneshot') and Save.keyframes['sound_oneshot'].size() > 0 and Timeline.oneshot_sound_track.get_child_count() > 0:
		var arr = Save.keyframes['sound_oneshot'].filter(func(sound): return Global.song_pos >= sound['timestamp'])
		sound_index = arr.size()
		if sound_index != last_sound_index:
			last_sound_index = sound_index
			run_sound(sound_index-1)

func run_sound(idx: int):
	if !$"../Music".playing: return
	if idx < 0: idx = 0
	var sound = Save.keyframes['sound_oneshot'][idx]['path']
	stream = Assets.get_asset(sound)
	play()

func _input(event):
	Global.scratch_playback(event, self)
