extends Node2D

var note_pos: float
var note_offset: float

func _ready():
	# Globalize Tracks
	Timeline.key_controller = self
	Timeline.guideline_container = $Indicators
	
	Timeline.animations_track = $AnimationsTrack
	Timeline.oneshot_sound_track = $OneshotSoundTrack
	Timeline.shutter_track = $ShutterTrack
	
	Events.song_loaded.connect(_on_song_loaded)
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.update_scrolling.connect(_on_update_scrolling)

func _on_song_loaded():
	Global.clear_children(Timeline.guideline_container)
	create_ui()

func _on_chart_loaded():
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
	print('Generating More Timeline Indicators')
	for i in Global.song_beats_total:
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Indicators.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.BEAT)
	
	for i in Global.song_beats_total * 2:
		if i % 2 == 0: continue
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Indicators.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
	
	for i in Global.song_beats_total * 4:
		if i % 4 == 0: continue
		if i % 2 == 0: continue
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Indicators.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
	
	for i in Global.song_beats_total * 8:
		if i % 8 == 0: continue
		if i % 4 == 0: continue
		if i % 2 == 0: continue
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Indicators.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
	
	Events.emit_signal('update_snapping', Global.snapping_ratios.find(Global.snapping_factor))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	note_pos = Global.song_pos * Global.note_speed
	note_offset = (Global.offset * Global.note_speed)
	position.x = (note_pos - note_offset) + 960
	
	$AnimationsPanel.position.x = -position.x
	$OneshotSoundPanel.position.x = -position.x
	$ShutterPanel.position.x = -position.x
	
	$AnimationsGradient.position.x = -position.x
	$OneshotSoundGradient.position.x = -position.x
	$ShutterGradient.position.x = -position.x
	
	$AnimationsLabel.position.x = -position.x + 16
	$OneshotSoundLabel.position.x = -position.x + 16
	$ShutterLabel.position.x = -position.x + 16

func _on_update_scrolling(value):
	if position.y + value < 348:
		position.y = 348
	elif position.y + value > 548:
		position.y = 548
	else:
		position.y += value
