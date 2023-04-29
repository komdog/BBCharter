extends Label


var current_time_msec: float
var current_time_sec: float
var current_time_min: float

var total_time_msec: float
var total_time_sec: float
var total_time_min: float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	
	current_time_msec = fmod(Global.song_pos, 1) * 1000
	current_time_sec = fmod(Global.song_pos, 60)
	current_time_min = fmod(Global.song_pos, 60 * 60) / 60
	
	total_time_msec = fmod(Global.song_length, 1) * 1000
	total_time_sec = fmod(Global.song_length, 60)
	total_time_min = fmod(Global.song_length, 60 * 60) / 60
	
	var format_array = [
		current_time_min, 
		current_time_sec, 
		current_time_msec,
		total_time_min, 
		total_time_sec,
		total_time_msec
	]
	
	text = "%02d:%02d.%02d : %02d:%02d.%02d" % format_array
