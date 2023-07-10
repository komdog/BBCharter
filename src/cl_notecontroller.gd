extends Node2D

var note_pos: float
var note_offset: float

var modifiers: int

func _ready():
	# Globalize Tracks
	Timeline.note_controller = self
	Timeline.beat_container = $Beat
	Timeline.half_container = $Half
	Timeline.third_container = $Third
	Timeline.quarter_container = $Quarter
	Timeline.sixth_container = $Sixth
	Timeline.eighth_container = $Eighth
	Timeline.note_container = $Notes
	
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.song_loaded.connect(_on_song_loaded)
	Events.note_created.connect(_on_note_created)
	Events.update_bpm.connect(_on_update_bpm)

func _on_chart_loaded():
	print('Spawning Notes')
	for note in Global.current_chart:
		var new_note = Prefabs.note.instantiate()
		new_note.setup(note)
		$Notes.add_child(new_note)

func _on_song_loaded():
	modifiers = Timeline.modifier_track.get_child_count()
	Global.clear_children(Timeline.beat_container)
	Global.clear_children(Timeline.half_container)
	Global.clear_children(Timeline.third_container)
	Global.clear_children(Timeline.quarter_container)
	Global.clear_children(Timeline.sixth_container)
	Global.clear_children(Timeline.eighth_container)
	create_ui()

# Create the indicators / Seperators in the timeline
func create_ui():
	print('Generating New Timeline Indicators')
	for i in Global.song_beats_total + 1:
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Beat.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.BEAT)
	
	for i in Global.song_beats_total * 2:
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Half.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
	
	for i in Global.song_beats_total * 3:
		if i % 3 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Third.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.THIRD_BEAT)
	
	for i in Global.song_beats_total * 4:
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Quarter.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
	
	for i in Global.song_beats_total * 6:
		if i % 3 == 0: continue
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Sixth.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
	
	for i in Global.song_beats_total * 8:
		if i % 2 == 0: continue
		var new_beat_indicator = Prefabs.beat_indicator.instantiate()
		$Eighth.add_child(new_beat_indicator)
		new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
	
	Events.emit_signal('update_snapping', Global.snapping_ratios.find(Global.snapping_factor))

func reset_indicators():
	var difference = Global.song_beats_total + 1 - $Beat.get_child_count()
	if difference != 0:
		for i in range(Global.song_beats_total - difference + 1, Global.song_beats_total + 1, 1 if difference>0 else -1):
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Beat.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.BEAT)
			else:
				$Beat.remove_child($Beat.get_child($Beat.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 2, Global.song_beats_total * 2, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Half.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
			else:
				$Half.remove_child($Half.get_child($Half.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 3, Global.song_beats_total * 3, 1 if difference>0 else -1):
			if i % 3 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Third.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.THIRD_BEAT)
			else:
				$Third.remove_child($Third.get_child($Third.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 4, Global.song_beats_total * 4, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Quarter.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
			else:
				$Quarter.remove_child($Quarter.get_child($Quarter.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 6, Global.song_beats_total * 6, 1 if difference>0 else -1):
			if i % 3 == 0: continue
			if i % 2 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Sixth.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
			else:
				$Sixth.remove_child($Sixth.get_child($Sixth.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 8, Global.song_beats_total * 8, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_beat_indicator = Prefabs.beat_indicator.instantiate()
				$Eighth.add_child(new_beat_indicator)
				new_beat_indicator.setup(i, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
			else:
				$Eighth.remove_child($Eighth.get_child($Eighth.get_child_count()-1))
	
	Events.emit_signal('update_snapping', Global.snapping_ratios.find(Global.snapping_factor))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	note_pos = Global.song_pos * Global.note_speed
	note_offset = Global.offset * Global.note_speed
	position.x = note_pos - note_offset
	
	$Gradient.position.x = -position.x - 960
	$Label.position.x = -position.x - 944

# Add Physical note to timeline
func _on_note_created(new_note_data):
	Global.project_saved = false
	var new_note = Prefabs.note.instantiate()
	new_note.setup(new_note_data)
	$Notes.add_child(new_note)

# Changes BPM of the song for charting
func _physics_process(_delta):
	if modifiers != Timeline.modifier_track.get_child_count():
		modifiers = Timeline.modifier_track.get_child_count()

func _on_update_bpm():
	if Global.project_loaded: reset_indicators()
