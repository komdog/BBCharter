extends Node2D

var shutter_index: int
var last_shutter_index: int

func _ready():
	Events.song_loaded.connect(_on_song_loaded)

func _on_song_loaded():
	shutter_index = 0
	last_shutter_index = 0

func _process(_delta):
	if Save.keyframes.has('shutter') and Save.keyframes['shutter'].size() > 0 and Timeline.shutter_track.get_child_count() > 0:
		var arr = Save.keyframes['shutter'].filter(func(shutter): return Global.song_pos >= shutter['timestamp'])
		shutter_index = arr.size()
		if shutter_index != last_shutter_index:
			last_shutter_index = shutter_index
			$AnimationPlayer.play("Shutters"); $AnimationPlayer.seek(0, true)
