extends AudioStreamPlayer

var song_position_raw: float
var pause_pos: float

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.chart_loaded.connect(_on_chart_loaded)
	Global.music = self
	
func _on_chart_loaded():
	Timeline.reset()
	
func _input(event):
	
	if Popups.open: return
	
	# Zooming
	if event.is_action_pressed("ui_accept"):
		if playing:
			playing = false
			pause_pos = song_position_raw
		else:
			playing = true
			seek(pause_pos)

func _process(_delta):
		if playing: 
			# Get raw song position for pausing
			song_position_raw = (
				get_playback_position() 
				+ AudioServer.get_time_since_last_mix()
				- AudioServer.get_output_latency()
			)

		Global.song_pos = song_position_raw
