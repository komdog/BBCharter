extends Panel

var animation_name: String
var timestamp: float

func _ready():
	Events.popups_opened.connect(_on_popups_opened)
	Events.popups_closed.connect(_on_popups_closed)
	Events.add_animation_to_timeline.connect(_on_add_animation_to_timeline)

func _on_popups_opened():
	if Popups.id == 0:
		$Label.text == "Place New Animation"
	else:
		$Label.text == "Edit Animation"

func _on_create_button_up() -> void:
	var new_animation_key =	{
		"timestamp": Global.get_timestamp_snapped(),
		"sheet_data": {"h": $SheetH.value, "v": $SheetV.value, "total": $Total.value},
		"scale_multiplier": $Scale.value,
		"position_offset": {"x": $OffsetX.value ,"y": $OffsetY.value},
		"animations": {
			"normal": animation_name,
			"horny": $Horny.text if $Horny.text != "" else animation_name
			}
		}

	if Popups.id == 0:
		for animation in Timeline.animations_track.get_children():
			if snappedf(animation['data']['timestamp'], 0.001) == snappedf(new_animation_key['timestamp'], 0.001):
				print('Animation already exists at %s' % [Global.get_synced_song_pos()])
				return
	else:
		new_animation_key['timestamp'] = timestamp
		for animation in Timeline.animations_track.get_children():
			if snappedf(animation['data']['timestamp'], 0.001) == snappedf(new_animation_key['timestamp'], 0.001):
				Timeline.delete_keyframe('loops', animation, Save.keyframes['loops'].find(animation['data']))

	Global.project_saved = false
	Save.keyframes['loops'].append(new_animation_key)
	Save.keyframes['loops'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Timeline.note_controller.spawn_single_keyframe(new_animation_key, Prefabs.animation_keyframe, Timeline.animations_track)
	Popups.close()
	print(new_animation_key)


func _on_cancel_button_up():
	Popups.close()

func _on_popups_closed():
	$Horny.clear()
	$SheetH.value = 2
	$SheetV.value = 3
	$Total.value = 6
	$OffsetX.value = 0
	$OffsetY.value = 0
	$Scale.value = 1
	
func _on_add_animation_to_timeline(asset_path):
	if Popups.id == 0:
		animation_name = asset_path
	else:
		animation_name = asset_path['animations']['normal']
		timestamp = asset_path['timestamp']
		$SheetH.value = asset_path['sheet_data']['h']
		$SheetV.value = asset_path['sheet_data']['v']
		$Total.value = asset_path['sheet_data']['total']
		
		if !asset_path['animations'].has('horny'):
			$Horny.text = animation_name
		if !asset_path.has('position_offset'):
			$OffsetX.value = 0
			$OffsetY.value = 0
		if !asset_path.has('scale_multiplier'):
			$Scale.value = 1
	
	Popups.reveal(Popups.PLACEANIMATION)
