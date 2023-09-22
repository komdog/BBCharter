extends PopupMenu

enum {SHUTTER,MODIFIER,SOUNDLOOP,VOICEBANK}

func _ready():
	Events.project_loaded.connect(_on_project_loaded)

func _on_id_pressed(id: int):
	var time: float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	
	match id:
		SHUTTER:
			var new_shutter = {'timestamp': time}
			for shutter in Timeline.shutter_track.get_children(): if snappedf(shutter['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				if Global.replacing_allowed:
					Timeline.delete_keyframe('shutter', shutter, Save.keyframes['shutter'].find(shutter['data']))
				else:
					Events.emit_signal('notify', 'Shutter Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
					return
			Save.keyframes['shutter'].append(new_shutter)
			Save.keyframes['shutter'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			Timeline.key_controller.spawn_single_keyframe(new_shutter, Prefabs.shutter_keyframe, Timeline.shutter_track)
		MODIFIER:
			if time < 0: time = 0
			var new_bpm = {'bpm': Global.get_current_bpm(), 'timestamp': time}
			for bpm in Timeline.modifier_track.get_children(): if snappedf(bpm['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				if Global.replacing_allowed:
					Timeline.delete_keyframe('shutter', bpm, Save.keyframes['shutter'].find(bpm['data']))
				else:
					Events.emit_signal('notify', 'Modifier Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
					return
			Save.keyframes['modifiers'].append(new_bpm)
			Save.keyframes['modifiers'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			Timeline.key_controller.spawn_single_keyframe(new_bpm, Prefabs.modifier_keyframe, Timeline.modifier_track)
			Global.reload_bpm()
		SOUNDLOOP:
			var new_sfx = {'path': '', 'timestamp': time}
			for sfx in Timeline.sfx_track.get_children(): if snappedf(sfx['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				if Global.replacing_allowed:
					Timeline.delete_keyframe('sound_loop', sfx, Save.keyframes['sound_loop'].find(sfx['data']))
				else:
					Events.emit_signal('notify', 'Sound Loop Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
					return
			Save.keyframes['sound_loop'].append(new_sfx)
			Save.keyframes['sound_loop'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			Timeline.key_controller.spawn_single_keyframe(new_sfx, Prefabs.sfx_keyframe, Timeline.sfx_track)
		VOICEBANK:
			var new_bank = {'voice_paths': [], 'timestamp': time}
			for bank in Timeline.voice_banks_track.get_children(): if snappedf(bank['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				if Global.replacing_allowed:
					Timeline.delete_keyframe('voice_bank', bank, Save.keyframes['voice_bank'].find(bank['data']))
				else:
					Events.emit_signal('notify', 'Sound Loop Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
					return
			Save.keyframes['voice_bank'].append(new_bank)
			Save.keyframes['voice_bank'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			Timeline.key_controller.spawn_single_keyframe(new_bank, Prefabs.voice_keyframe, Timeline.voice_banks_track)
	
	Global.project_saved = false

func _on_project_loaded():
	for i in item_count:
		set_item_disabled(i, false)
