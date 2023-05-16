extends AudioStreamPlayer

var sound_loop_index: int = 0
var last_sound_loop_index: int = 0

func _ready() -> void:
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.hit_note.connect(_on_hit_note)
	
func _on_chart_loaded():
	stream = null
	sound_loop_index = 0
	change_sound(sound_loop_index)

func _physics_process(_delta):
	if Save.keyframes.has('sound_loop') and Save.keyframes['sound_loop'].size() > 0:
		var arr = Save.keyframes['sound_loop'].filter(func(loop): return Global.get_synced_song_pos() >= loop['timestamp'])
		sound_loop_index = arr.size()
		if sound_loop_index != last_sound_loop_index:
			last_sound_loop_index = sound_loop_index
			change_sound(sound_loop_index-1)
	
func change_sound(idx: int):
	if Save.keyframes['sound_loop'].is_empty(): return
	if Save.keyframes['sound_loop'].size() <= idx: return
	var sound = Save.keyframes['sound_loop'][idx]
	stream = Assets.get_asset(sound['path'])

func _on_hit_note(_data) -> void:
	play()
			
