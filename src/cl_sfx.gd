extends AudioStreamPlayer

var sound_loop_index: int
var last_sound_loop_index: int

func _ready():
	Events.song_loaded.connect(_on_song_loaded)
	Events.hit_note.connect(_on_hit_note)

func _on_song_loaded():
	stream = null
	sound_loop_index = 0; last_sound_loop_index = 0
	change_sound(sound_loop_index)

func _physics_process(_delta):
	if Save.keyframes.has('sound_loop') and Save.keyframes['sound_loop'].size() > 0 and Timeline.sfx_track.get_child_count() > 0:
		var arr = Save.keyframes['sound_loop'].filter(func(loop): return Global.song_pos >= loop['timestamp'])
		sound_loop_index = arr.size()
		if sound_loop_index != last_sound_loop_index and Global.song_pos >= Save.keyframes['sound_loop'][0]['timestamp']:
			last_sound_loop_index = sound_loop_index
			change_sound(sound_loop_index-1)

func change_sound(idx: int):
	if Save.keyframes['sound_loop'].is_empty(): return
	if Save.keyframes['sound_loop'].size() <= idx: return
	var sound = Save.keyframes['sound_loop'][idx]
	stream = Assets.get_asset(sound['path'])

func _on_hit_note(_data):
	if Save.keyframes['sound_loop'].size() > 0: play()
