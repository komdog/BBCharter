extends Node2D

var note_pos: float
var note_offset: float
var bpm_offset: float

var bpm_index: int
var last_bpm_index: int

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
	bpm_index = 0; last_bpm_index = 0; Global.bpm_index = 0
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
	var difference = Global.song_beats_total*8 - $Eighth.get_child_count()*2
	if difference > 0:
		for i in difference+1:
			if i % 8 == 0: continue
			if i % 4 == 0: continue
			if i % 2 == 0: continue
			var index = $Beat.get_child_count()*8-8+i
			if $Eighth.get_child($Eighth.get_child_count()-1).indicator_index == index: index += 1
			if $Quarter.get_child($Quarter.get_child_count()-1).indicator_index*2 == index: index += 1
			if $Eighth.get_child($Eighth.get_child_count()-1).indicator_index-2 == index: index += 4
			if $Quarter.get_child($Quarter.get_child_count()-1).indicator_index*2-5 == index: index += 6
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(index, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
			$Eighth.add_child(new_beat_indicator)
	elif difference < 0:
		for beat in $Eighth.get_children():
			if beat.get_index() > float(Global.song_eighths_total-1)/2: $Eighth.remove_child(beat)
	
	difference = Global.song_beats_total*6 - $Sixth.get_child_count()*3
	if difference > 0:
		for i in difference+1:
			if int(i) % 6 == 0: continue
			if int(i) % 3 == 0: continue
			if int(i) % 2 == 0: continue
			var index = $Beat.get_child_count()*6-6+i
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(index, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
			$Sixth.add_child(new_beat_indicator)
	elif difference < 0:
		for beat in $Sixth.get_children():
			if beat.get_index() > float(Global.song_beats_total*6-1)/3: $Sixth.remove_child(beat)
	
	difference = Global.song_beats_total*4 - $Quarter.get_child_count()*2
	if difference > 0:
		for i in difference+1:
			if i % 4 == 0: continue
			if i % 2 == 0: continue
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup($Beat.get_child_count()*4-4+i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
			$Quarter.add_child(new_beat_indicator)
	elif difference < 0:
		for beat in $Quarter.get_children():
			if beat.get_index() > float(Global.song_beats_total*4-1)/2: $Quarter.remove_child(beat)
	
	difference = Global.song_beats_total*3-1 - $Third.get_child_count()*1.5
	if difference > 0:
		for i in difference+1:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup($Beat.get_child_count()*3-3+i, Enums.UI_INDICATOR_TYPE.THIRD_BEAT)
			$Third.add_child(new_beat_indicator)
	elif difference < 0:
		for beat in $Third.get_children():
			if beat.get_index() > float(Global.song_beats_total*3-1)/1.5: $Third.remove_child(beat)
	
	difference = Global.song_beats_total*2 - $Half.get_child_count()*2
	if difference > 0:
		for i in difference+1:
			if i % 2 == 0: continue
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup($Beat.get_child_count()*2-2+i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
			$Half.add_child(new_beat_indicator)
	elif difference < 0:
		for beat in $Half.get_children():
			if beat.get_index() > float(Global.song_beats_total*2-1)/2: $Half.remove_child(beat)
	
	difference = Global.song_beats_total+1 - $Beat.get_child_count()
	if difference > 0:
		for i in difference:
			var index = $Beat.get_child_count()
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(index, Enums.UI_INDICATOR_TYPE.BEAT)
			$Beat.add_child(new_beat_indicator)
	elif difference < 0:
		for beat in $Beat.get_children():
			if beat.get_index() > Global.song_beats_total: $Beat.remove_child(beat)
	
	var nega_beat = Global.beat_offset / Global.beat_length_msec
	if nega_beat > 0 and nega_beat < 1:
		if nega_beat >= 0.125:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-1, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
			$Eighth.add_child(new_beat_indicator)
		if nega_beat >= 1.0/6.0:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-1, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
			$Sixth.add_child(new_beat_indicator)
		if nega_beat >= 0.25:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-1, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
			$Quarter.add_child(new_beat_indicator)
		if nega_beat >= 1.0/3.0:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-1, Enums.UI_INDICATOR_TYPE.THIRD_BEAT)
			$Third.add_child(new_beat_indicator)
		if nega_beat >= 0.375:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-3, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
			$Eighth.add_child(new_beat_indicator)
		if nega_beat >= 0.5:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-1, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
			$Half.add_child(new_beat_indicator)
		if nega_beat >= 2.0/3.0:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-1, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
			$Sixth.add_child(new_beat_indicator)
		if nega_beat >= 0.625:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-5, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
			$Eighth.add_child(new_beat_indicator)
		if nega_beat >= 0.75:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-3, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
			$Quarter.add_child(new_beat_indicator)
		if nega_beat >= 0.875:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-7, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
			$Eighth.add_child(new_beat_indicator)
		if nega_beat == 1:
			var new_beat_indicator = Prefabs.beat_indicator.instantiate()
			new_beat_indicator.setup(-1, Enums.UI_INDICATOR_TYPE.BEAT)
			$Beat.add_child(new_beat_indicator)
	else:
		for beat in $Beat.get_children(): if beat.indicator_index < 0: $Beat.remove_child(beat)
		for beat in $Half.get_children(): if beat.indicator_index < 0: $Half.remove_child(beat)
		for beat in $Quarter.get_children(): if beat.indicator_index < 0: $Quarter.remove_child(beat)
		for beat in $Eighth.get_children(): if beat.indicator_index < 0: $Eighth.remove_child(beat)
	
	Events.emit_signal('update_snapping', Global.snapping_ratios.find(Global.snapping_factor))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	note_pos = Global.song_pos * Global.note_speed
	note_offset = Global.offset * Global.note_speed
	bpm_offset = Global.bpm_offset * Global.note_speed
	position.x = note_pos - note_offset - bpm_offset
	
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
	if Save.keyframes.has('modifiers') and Save.keyframes['modifiers'].size() > 0 and Timeline.modifier_track.get_child_count() > 0:
		var arr = Save.keyframes['modifiers'].filter(func(bpm): return Global.song_pos >= bpm['timestamp'])
		bpm_index = arr.size()
		if bpm_index != last_bpm_index:
			Global.bpm_index = bpm_index
			change_bpm(bpm_index-1)
			if Save.keyframes['modifiers'].size() <= 1: if last_bpm_index > 1: Global.reload_bpm()
			last_bpm_index = bpm_index
	
	if modifiers != Timeline.modifier_track.get_child_count():
		change_bpm(bpm_index-1)
		modifiers = Timeline.modifier_track.get_child_count()

func change_bpm(idx: int):
	if idx < 0: idx = 0
	Global.bpm = Save.keyframes['modifiers'][idx]['bpm']
	Global.bpm_offset = Save.keyframes['modifiers'][idx]['timestamp']
	var bpm = Save.keyframes['modifiers'][idx-1]['bpm']; var time = Save.keyframes['modifiers'][idx-1]['timestamp']
	Global.beat_offset = (float(60.0/Global.bpm)-Global.bpm_offset) + (float(60.0/bpm)-time/(60.0/bpm))
	if Global.beat_offset < 0: Global.beat_offset = 0
	if Save.keyframes['modifiers'].size() > 1 and last_bpm_index >= 1 and bpm_index > 0: Global.reload_bpm(idx)
	else: if Global.bpm != Global.global_bpm: Global.reload_bpm()

func _on_update_bpm():
	if Global.project_loaded: reset_indicators()
