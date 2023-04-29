extends Control

var asset_type: int
var asset_path

func setup_asset_note(asset_name):
	
	tooltip_text = asset_name
	
	asset_path = asset_name
	
	if Assets.lib[asset_name] is ImageTexture:
		$Background/Icon.texture = Assets.lib[asset_name]
		asset_type = Enums.ASSET.IMAGE
		
	elif Assets.lib[asset_name] is AudioStreamMP3:
		$Background/Icon.texture = Prefabs.audio_icon
		asset_type = Enums.ASSET.AUDIO
		$Preview.stream = Assets.lib[asset_name]
		
	else:
		print("Uncategorized: %s" % asset_name)
		
	

func _process(_delta):
	$Background/Icon.modulate = Color.DARK_SEA_GREEN if $Preview.playing else Color.WHITE


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
	if $Preview.playing:
		$Preview.stop()
	else:
		$Preview.stop()
		$Preview.play()
		
		
func add_sound_oneshot_to_timeline():
	var new_sound_oneshot_key =	{
		"timestamp": Global.get_timestamp_snapped(),
		"path": asset_path
	}
		
	print(new_sound_oneshot_key)
	Save.keyframes['sound_oneshot'].append(new_sound_oneshot_key)
	Save.keyframes['sound_oneshot'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Timeline.note_controller.spawn_single_keyframe(new_sound_oneshot_key, Prefabs.oneshot_keyframe, Timeline.oneshot_sound_track)
	
# TODO: FIND A WAY TO STORE ASSETS WITH DATA
func show_animation_prompt():
	Events.emit_signal('add_animation_to_timeline', asset_path)
	
	
#func add_animation_to_timeline()
#	var new_animation_key =	{
#		"timestamp": Global.get_timestamp_snapped(),
#		"sheet_data": {"h": 2, "v": 3, "total": 6},
#		"scale_multiplier": 1.0,
#		"position_offset": {"x": 0 ,"y": 0},
#		"animations": {
#			"normal": asset_path,
#			"horny": asset_path
#			}
#		}
#
#	Save.keyframes['loops'].append(new_animation_key)
#	Save.keyframes['loops'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
#	Timeline.note_controller.spawn_single_keyframe(new_animation_key, Prefabs.animation_keyframe, Timeline.animations_track)
#
#
	
