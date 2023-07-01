extends Control

var asset_type: int
var asset_path

var icon: TextureRect
var music_preview: AudioStreamPlayer
var filename: Label

func setup_asset_note(asset_name):
	icon = $Icon
	music_preview = $Preview
	filename = $Filename
	
	tooltip_text = asset_name
	
	asset_path = asset_name
	filename.text = asset_path
	
	if Assets.lib[asset_name] is ImageTexture:
		icon.texture = Assets.lib[asset_name]
		asset_type = Enums.ASSET.IMAGE
	
	elif Assets.lib[asset_name] is AudioStreamMP3:
		icon.texture = Prefabs.audio_icon
		asset_type = Enums.ASSET.AUDIO
		music_preview.stream = Assets.lib[asset_name]
	else:
		print("Uncategorized: %s" % asset_name)

func _process(_delta):
	icon.modulate = Color.DARK_SEA_GREEN if music_preview.playing else Color.WHITE

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if asset_type == Enums.ASSET.AUDIO:
					add_sound_oneshot_to_timeline()
				if asset_type == Enums.ASSET.IMAGE:
					Events.emit_signal('add_animation_to_timeline', asset_path)
			MOUSE_BUTTON_MIDDLE:
				if asset_type == Enums.ASSET.AUDIO:
					preview_audio()
			MOUSE_BUTTON_RIGHT:
				if asset_type == Enums.ASSET.AUDIO:
					Events.emit_signal('open_audio_menu', asset_path, get_window().get_mouse_position())
				if asset_type == Enums.ASSET.IMAGE:
					Events.emit_signal('open_image_menu', asset_path, get_window().get_mouse_position())

func preview_audio():
	if music_preview.playing:
		music_preview.stop()
	else:
		music_preview.stop()
		music_preview.play()

func add_sound_oneshot_to_timeline():
	var time: float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	
	var new_sound_oneshot_key = {"timestamp": time, "path": asset_path}
	print(new_sound_oneshot_key)
	for oneshot in Timeline.oneshot_sound_track.get_children():
		if snappedf(oneshot['data']['timestamp'], 0.001) == snappedf(time, 0.001):
			if Global.replacing_allowed:
				Timeline.delete_keyframe('sound_oneshot', oneshot, Save.keyframes['sound_oneshot'].find(oneshot['data']))
			else:
				Events.emit_signal('notify', 'Oneshot Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
				return
	Save.keyframes['sound_oneshot'].append(new_sound_oneshot_key)
	Save.keyframes['sound_oneshot'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Timeline.key_controller.spawn_single_keyframe(new_sound_oneshot_key, Prefabs.oneshot_keyframe, Timeline.oneshot_sound_track)
	Global.project_saved = false
