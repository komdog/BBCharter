extends Node2D

var note_pos: float
var note_offset: float

func _ready():
	# Globalize Tracks
	Timeline.key_controller = self
	
	Timeline.key_beat_container = $Beat
	Timeline.key_half_container = $Half
	Timeline.key_third_container = $Third
	Timeline.key_quarter_container = $Quarter
	Timeline.key_sixth_container = $Sixth
	Timeline.key_eighth_container = $Eighth
	
	Timeline.shutter_track = $ShutterTrack
	Timeline.animations_track = $AnimationsTrack
	Timeline.effects_track = $EffectsTrack
	Timeline.backgrounds_track = $BackgroundsTrack
	Timeline.modifier_track = $ModifierTrack
	Timeline.sfx_track = $SoundLoopsTrack
	Timeline.oneshot_sound_track = $OneshotSoundTrack
	Timeline.voice_banks_track = $VoiceBanksTrack
	
	Events.song_loaded.connect(_on_song_loaded)
	Events.update_scrolling.connect(_on_update_scrolling)
	Events.update_bpm.connect(_on_update_bpm)

func _on_song_loaded():
	spawn_keyframes('shutter', Prefabs.shutter_keyframe, Timeline.shutter_track)
	spawn_keyframes('loops', Prefabs.animation_keyframe, Timeline.animations_track)
	spawn_keyframes('background', Prefabs.background_keyframe, Timeline.backgrounds_track)
	spawn_keyframes('effects', Prefabs.effect_keyframe, Timeline.effects_track)
	spawn_keyframes('modifiers', Prefabs.modifier_keyframe, Timeline.modifier_track)
	spawn_keyframes('sound_loop', Prefabs.sfx_keyframe, Timeline.sfx_track)
	spawn_keyframes('sound_oneshot', Prefabs.oneshot_keyframe, Timeline.oneshot_sound_track)
	spawn_keyframes('voice_bank', Prefabs.voice_keyframe, Timeline.voice_banks_track)
	Global.clear_children(Timeline.key_beat_container)
	Global.clear_children(Timeline.key_half_container)
	Global.clear_children(Timeline.key_third_container)
	Global.clear_children(Timeline.key_quarter_container)
	Global.clear_children(Timeline.key_sixth_container)
	Global.clear_children(Timeline.key_eighth_container)
	create_ui()

# Add sprites of the animation keyframes to timeline
func spawn_keyframes(section_name: String, prefab: PackedScene, parent: Node):
	# Spawn Corresponding Keyframe Prefab
	if Save.keyframes.has(section_name):
		if Save.keyframes[section_name].size() > 0: for keyframe_data in Save.keyframes[section_name]:
			spawn_single_keyframe(keyframe_data, prefab, parent)
	else:
		Save.keyframes[section_name] = []

func spawn_single_keyframe(keyframe_data, prefab: PackedScene, parent: Node):
	var new_keyframe = prefab.instantiate()
	new_keyframe.setup(keyframe_data)
	parent.add_child(new_keyframe)

# Create the indicators / Seperators in the timeline
func create_ui():
	print('Generating More Timeline Indicators')
	for i in Global.song_beats_total + 1:
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Beat.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.BEAT)
	
	for i in Global.song_beats_total * 2:
		if i % 2 == 0: continue
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Half.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
	
	for i in Global.song_beats_total * 3:
		if i % 3 == 0: continue
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Third.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.THIRD_BEAT)
	
	for i in Global.song_beats_total * 4:
		if i % 2 == 0: continue
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Quarter.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
	
	for i in Global.song_beats_total * 6:
		if i % 3 == 0: continue
		if i % 2 == 0: continue
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Sixth.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
	
	for i in Global.song_beats_total * 8:
		if i % 2 == 0: continue
		var new_key_indicator = Prefabs.key_indicator.instantiate()
		$Eighth.add_child(new_key_indicator)
		new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)

func reset_indicators():
	var difference = Global.song_beats_total + 1 - $Beat.get_child_count()
	if difference != 0:
		for i in range(Global.song_beats_total - difference + 1, Global.song_beats_total + 1, 1 if difference>0 else -1):
			if difference > 0:
				var new_key_indicator = Prefabs.key_indicator.instantiate()
				$Beat.add_child(new_key_indicator)
				new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.BEAT)
			else:
				$Beat.remove_child($Beat.get_child($Beat.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 2, Global.song_beats_total * 2, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_key_indicator = Prefabs.key_indicator.instantiate()
				$Half.add_child(new_key_indicator)
				new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.HALF_BEAT)
			else:
				$Half.remove_child($Half.get_child($Half.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 3, Global.song_beats_total * 3, 1 if difference>0 else -1):
			if i % 3 == 0: continue
			if difference > 0:
				var new_key_indicator = Prefabs.key_indicator.instantiate()
				$Third.add_child(new_key_indicator)
				new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.THIRD_BEAT)
			else:
				$Third.remove_child($Third.get_child($Third.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 4, Global.song_beats_total * 4, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_key_indicator = Prefabs.key_indicator.instantiate()
				$Quarter.add_child(new_key_indicator)
				new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.QUARTER_BEAT)
			else:
				$Quarter.remove_child($Quarter.get_child($Quarter.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 6, Global.song_beats_total * 6, 1 if difference>0 else -1):
			if i % 3 == 0: continue
			if i % 2 == 0: continue
			if difference > 0:
				var new_key_indicator = Prefabs.key_indicator.instantiate()
				$Sixth.add_child(new_key_indicator)
				new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.SIXTH_BEAT)
			else:
				$Sixth.remove_child($Sixth.get_child($Sixth.get_child_count()-1))
	
		for i in range((Global.song_beats_total - difference) * 8, Global.song_beats_total * 8, 1 if difference>0 else -1):
			if i % 2 == 0: continue
			if difference > 0:
				var new_key_indicator = Prefabs.key_indicator.instantiate()
				$Eighth.add_child(new_key_indicator)
				new_key_indicator.setup(i, Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT)
			else:
				$Eighth.remove_child($Eighth.get_child($Eighth.get_child_count()-1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	note_pos = Global.song_pos * Global.note_speed
	note_offset = Global.offset * Global.note_speed
	position.x = note_pos - note_offset + 960
	
	$ShutterPanel.position.x = -position.x; $ShutterGradient.position.x = -position.x
	$AnimationsPanel.position.x = -position.x; $AnimationsGradient.position.x = -position.x
	$EffectsPanel.position.x = -position.x; $EffectsGradient.position.x = -position.x
	$BackgroundsPanel.position.x = -position.x; $BackgroundsGradient.position.x = -position.x
	$ModifierPanel.position.x = -position.x; $ModifierGradient.position.x = -position.x
	$SoundLoopsPanel.position.x = -position.x; $SoundLoopsGradient.position.x = -position.x
	$OneshotSoundPanel.position.x = -position.x; $OneshotSoundGradient.position.x = -position.x
	$VoiceBanksPanel.position.x = -position.x; $VoiceBanksGradient.position.x = -position.x
	
	$ShutterLabel.position.x = -position.x + 16
	$AnimationsLabel.position.x = -position.x + 16
	$EffectsLabel.position.x = -position.x + 16
	$BackgroundsLabel.position.x = -position.x + 16
	$ModifierLabel.position.x = -position.x + 16
	$SoundLoopsLabel.position.x = -position.x + 16
	$OneshotSoundLabel.position.x = -position.x + 16
	$VoiceBanksLabel.position.x = -position.x + 16

func _on_update_scrolling(value):
	if position.y + value < 175: position.y = 175
	elif position.y + value > 528: position.y = 528
	else: position.y += value

func _on_update_bpm():
	if Global.project_loaded: reset_indicators()
