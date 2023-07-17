extends PopupMenu

enum {ADDANIMATION,ADDEFFECT,ADDBACKGROUND,SETICON}

var asset_path

func _ready():
	Events.open_image_menu.connect(_on_open_image_menu)

func _on_open_image_menu(path,pos):
	asset_path = path
	visible = true
	position = pos

func _on_id_pressed(id: int):
	var time: float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	
	match id:
		ADDANIMATION:
			Popups.id = 0
			Events.emit_signal('add_animation_to_timeline', asset_path)
		ADDEFFECT:
			Popups.id = 0
			Events.emit_signal('add_effect_to_timeline', asset_path)
		ADDBACKGROUND:
			if time < 0: time = 0
			var new_background_key = {"path": asset_path, "timestamp": time}
			for background in Timeline.backgrounds_track.get_children():
				if snappedf(background['data']['timestamp'], 0.001) == snappedf(time, 0.001):
					if Global.replacing_allowed:
						Timeline.delete_keyframe('background', background, Save.keyframes['background'].find(background['data']))
					else:
						Events.emit_signal('notify', 'Background Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
						return
			Save.keyframes['background'].append(new_background_key)
			Save.keyframes['background'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			Timeline.key_controller.spawn_single_keyframe(new_background_key, Prefabs.background_keyframe, Timeline.backgrounds_track)
			Global.project_saved = false
		SETICON:
			Save.notes["charts"][Global.difficulty_index]["icon"] = asset_path
			Events.emit_signal('notify', 'Difficulty Icon Set', asset_path, Save.project_dir + "/images/" + asset_path)
			Global.project_saved = false
