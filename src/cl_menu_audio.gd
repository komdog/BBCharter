extends PopupMenu

enum {ADDSOUNDLOOP,ADDONESHOT,ADDVOICEBANK}

var asset_path

func _ready():
	Events.open_audio_menu.connect(_on_open_audio_menu)

func _on_open_audio_menu(path,pos):
	asset_path = path
	show()
	position = pos

func _on_id_pressed(id: int):
	var time: float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	
	match id:
		ADDSOUNDLOOP:
			var new_sfx_key = {"path": asset_path, "timestamp": time}
			for sfx in Timeline.sfx_track.get_children():
				if snappedf(sfx['data']['timestamp'], 0.001) == snappedf(time, 0.001):
					if Global.replacing_allowed:
						Timeline.delete_keyframe('sound_loop', sfx, Save.keyframes['sound_loop'].find(sfx['data']))
					else:
						Events.emit_signal('notify', 'Sound Loop Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
						return
			Save.keyframes['sound_loop'].append(new_sfx_key)
			Save.keyframes['sound_loop'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			Timeline.key_controller.spawn_single_keyframe(new_sfx_key, Prefabs.sfx_keyframe, Timeline.sfx_track)
			Global.project_saved = false
		ADDONESHOT:
			var new_sound_oneshot_key = {"path": asset_path, "timestamp": time}
			for oneshot in Timeline.oneshot_sound_track.get_children():
				if snappedf(oneshot['data']['timestamp'], 0.001) == snappedf(new_sound_oneshot_key['timestamp'], 0.001):
					if Global.replacing_allowed:
						Timeline.delete_keyframe('sound_oneshot', oneshot, Save.keyframes['sound_oneshot'].find(oneshot['data']))
					else:
						Events.emit_signal('notify', 'Oneshot Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
						return
			Save.keyframes['sound_oneshot'].append(new_sound_oneshot_key)
			Save.keyframes['sound_oneshot'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			Timeline.key_controller.spawn_single_keyframe(new_sound_oneshot_key, Prefabs.oneshot_keyframe, Timeline.oneshot_sound_track)
			Global.project_saved = false
		ADDVOICEBANK:
			Popups.id = 0
			Events.emit_signal('add_voicebank_to_timeline', asset_path)
