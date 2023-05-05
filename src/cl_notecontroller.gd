extends Node2D

var note_pos: float
var note_offset: float


func _ready():
	
	Timeline.note_controller = self
	
	Timeline.indicator_container = $Indicators
	Timeline.note_container = $Notes
	
	# Globalize Tracks
	Timeline.animations_track = $AnimationsTrack
	Timeline.oneshot_sound_track = $OneshotSoundTrack
	Timeline.shutter_track = $ShutterTrack
	
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
		
	spawn_keyframes('loops', Prefabs.animation_keyframe, Timeline.animations_track)
	spawn_keyframes('sound_oneshot', Prefabs.oneshot_keyframe, Timeline.oneshot_sound_track)
	spawn_keyframes('shutter', Prefabs.shutter_keyframe, Timeline.shutter_track)

# Add sprites of the animation keyframes to timeline
func spawn_keyframes(section_name: String, prefab: PackedScene, parent: Node):
	
	# Spawn Corresponding Keyframe Prefab
	for keyframe_data in Save.keyframes[section_name]:
		spawn_single_keyframe(keyframe_data, prefab, parent)
		
func spawn_single_keyframe(keyframe_data, prefab: PackedScene, parent: Node):
	var new_keyframe = prefab.instantiate()
	new_keyframe.setup(keyframe_data)
	parent.add_child(new_keyframe)
	
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

# Add Physical note to timeline
func _on_note_created(new_note_data):
	Global.project_saved = false
	var new_note = Prefabs.note.instantiate()
	new_note.setup(new_note_data)
	$Notes.add_child(new_note)


	
