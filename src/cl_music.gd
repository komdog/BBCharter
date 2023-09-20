extends AudioStreamPlayer

var song_position_raw: float
var pause_pos: float

func _ready():
	Global.music = self

func _input(event):
	if Popups.open or Global.lock_timeline: return
	
	if event.is_action_pressed("ui_accept"):
		if playing:
			playing = false
			pause_pos = song_position_raw
		else:
			playing = true
			seek(pause_pos)

func _process(_delta):
	if Popups.open:
		playing = false
		pause_pos = song_position_raw
	
	if playing: 
		# Get raw song position for pausing
		song_position_raw = (get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency())
		Timeline.note_scroller.value = song_position_raw
	
	Global.song_pos = song_position_raw - Global.offset
