extends Node2D

var note_pos: float
var note_offset: float

func _ready():
	# Globalize Tracks
	Timeline.note_controller = self
	Timeline.indicator_container = $Indicators
	Timeline.note_container = $Notes
	
	Events.song_loaded.connect(_on_song_loaded)
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.note_created.connect(_on_note_created)

func _on_song_loaded():
	Global.clear_children(Timeline.indicator_container)
	create_ui()

func _on_chart_loaded():
	print('Spawning Notes')
	for note in Global.current_chart:
		var new_note = Prefabs.note.instantiate()
		new_note.setup(note)
		$Notes.add_child(new_note)

# Create the indicators / Seperators in the timeline
func create_ui():
	print('Generating New Timeline Indicators')
	for i in Global.song_beats_total:
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Indicators.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.BEAT)
	
	for i in Global.song_beats_total * 2:
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Indicators.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
	
	for i in Global.song_beats_total * 4:
		if i % 4 == 0: continue
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Indicators.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
	
	for i in Global.song_beats_total * 8:
		if i % 8 == 0: continue
		if i % 4 == 0: continue
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Indicators.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
	
	Events.emit_signal('update_snapping', Global.snapping_ratios.find(Global.snapping_factor))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	note_pos = Global.song_pos * Global.note_speed
	note_offset = (Global.offset * Global.note_speed)
	position.x = (note_pos - note_offset)
	
	$Gradient.position.x = -position.x - 960
	$Label.position.x = -position.x - 944

# Add Physical note to timeline
func _on_note_created(new_note_data):
	Global.project_saved = false
	var new_note = Prefabs.note.instantiate()
	new_note.setup(new_note_data)
	$Notes.add_child(new_note)
