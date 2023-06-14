extends AudioStreamPlayer


var sound_index: int
var last_sound_index: int

func _ready() -> void:
	Events.chart_loaded.connect(_on_chart_loaded)
	

	
func _on_chart_loaded():
	sound_index = 0


func _physics_process(_delta):
	if Save.keyframes.has('sound_oneshot') and Save.keyframes['sound_oneshot'].size() > 0 and Timeline.oneshot_sound_track.get_child_count() > 0:
		var arr = Save.keyframes['sound_oneshot'].filter(func(sound): return Global.get_synced_song_pos() >= sound['timestamp'])
		sound_index = arr.size()
		if sound_index != last_sound_index:
			last_sound_index = sound_index
			run_sound(sound_index-1)



func run_sound(idx: int) -> void:
	if idx < 0: return
	var sound = Save.keyframes['sound_oneshot'][idx]['path']
	stream = Assets.get_asset(sound)
	play()
	

