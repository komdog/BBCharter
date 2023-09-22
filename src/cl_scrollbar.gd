extends HScrollBar

func _ready():
	Events.song_loaded.connect(_on_song_loaded)
	Timeline.note_scroller = self

func _on_song_loaded():
	max_value = Global.song_length
	value = 0
	get_parent().show()

func _on_value_changed(_value):
	if snappedf(Global.music.song_position_raw, 0.001) != value:
		Global.music.song_position_raw = value
		Global.music.pause_pos = value
		Global.music.seek(value)
