extends PopupMenu

enum {SHUTTER}

func _ready():
	Events.project_loaded.connect(_on_project_loaded)


func _on_id_pressed(id: int):
	match id:
		SHUTTER:
			var new_shutter = {'timestamp': Global.get_timestamp_snapped()}
			for shutter in Timeline.shutter_track.get_children():
				if snappedf(shutter['data']['timestamp'], 0.001) == snappedf(new_shutter['timestamp'], 0.001):
					print('Shutter already exists at %s' % [Global.get_synced_song_pos()])
					return
	
			Global.project_saved = false
			Save.keyframes['shutter'].append(new_shutter)
			Save.keyframes['shutter'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			Timeline.note_controller.spawn_single_keyframe(new_shutter, Prefabs.shutter_keyframe, Timeline.shutter_track)

func _on_project_loaded():
	for i in item_count:
		set_item_disabled(i,false)
