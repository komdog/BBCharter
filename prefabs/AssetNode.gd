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
					show_animation_prompt()
			MOUSE_BUTTON_MIDDLE:
				pass
			MOUSE_BUTTON_RIGHT:
				if asset_type == Enums.ASSET.AUDIO:
					preview_audio()
					

func preview_audio():
	if music_preview.playing:
		music_preview.stop()
	else:
		music_preview.stop()
		music_preview.play()
		
		
func add_sound_oneshot_to_timeline():
	var new_sound_oneshot_key =	{
		"timestamp": Global.get_timestamp_snapped(),
		"path": asset_path
	}

	for oneshot in Timeline.oneshot_sound_track.get_children():
		if snappedf(oneshot['data']['timestamp'], 0.001) == snappedf(new_sound_oneshot_key['timestamp'], 0.001):
			print('Oneshot already exists at %s' % [Global.get_synced_song_pos()])
			return
			
	Global.project_saved = false
	print(new_sound_oneshot_key)
	Save.keyframes['sound_oneshot'].append(new_sound_oneshot_key)
	Save.keyframes['sound_oneshot'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Timeline.note_controller.spawn_single_keyframe(new_sound_oneshot_key, Prefabs.oneshot_keyframe, Timeline.oneshot_sound_track)
	
# TODO: FIND A WAY TO STORE ASSETS WITH DATA
func show_animation_prompt():
	Popups.id = 0
	Events.emit_signal('add_animation_to_timeline', asset_path)
