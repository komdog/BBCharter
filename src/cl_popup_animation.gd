extends Panel

var animation_name: String
var timestamp: float

func _ready():
	Events.popups_opened.connect(_on_popups_opened)
	Events.add_animation_to_timeline.connect(_on_add_animation_to_timeline)

func _on_popups_opened(_index):
	if Popups.id > 0:
		$Label.text = "Edit Animation"
		$Create.text = "Edit"
	else:
		$Label.text = "Place New Animation"
		$Create.text = "Create"

func _on_create_button_up():
	var time: float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	
	var new_animation_key = {
		"timestamp": time,
		"sheet_data": {"h": $SheetH.value, "v": $SheetV.value, "total": $Total.value},
		"scale_multiplier": $Scale.value,
		"position_offset": {"x": $OffsetX.value ,"y": $OffsetY.value},
		"animations": {
			"normal": animation_name,
			"horny": $Horny.text if $Horny.text != "" else animation_name
			}
		}
	
	if Popups.id > 0 or Global.replacing_allowed:
		if Popups.id > 0: new_animation_key['timestamp'] = timestamp
		for animation in Timeline.animations_track.get_children():
			if snappedf(animation['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				Timeline.delete_keyframe('loops', animation, Save.keyframes['loops'].find(animation['data']))
	
	Global.project_saved = false
	Save.keyframes['loops'].append(new_animation_key)
	Save.keyframes['loops'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Timeline.key_controller.spawn_single_keyframe(new_animation_key, Prefabs.animation_keyframe, Timeline.animations_track)
	_on_cancel_button_up()

func _on_cancel_button_up():
	Popups.close()
	Popups.id = -1
	reset()

func reset():
	$Horny.clear()
	$SheetH.value = 2
	$SheetV.value = 3
	$Total.value = 6
	$OffsetX.value = 0
	$OffsetY.value = 0
	$Scale.value = 1.0

func _on_add_animation_to_timeline(asset_path):
	if Popups.id > 0:
		animation_name = asset_path['animations']['normal']
		timestamp = asset_path['timestamp']
		$SheetH.value = asset_path['sheet_data']['h']
		$SheetV.value = asset_path['sheet_data']['v']
		$Total.value = asset_path['sheet_data']['total']
		
		if asset_path['animations'].has('horny'):
			$Horny.text = asset_path['animations']['horny']
		else:
			$Horny.text = animation_name
		if asset_path.has('position_offset'):
			if asset_path['position_offset'].has('x'):
				$OffsetX.value = asset_path['position_offset']['x']
			else:
				$OffsetX.value = 0
			if asset_path['position_offset'].has('y'):
				$OffsetY.value = asset_path['position_offset']['y']
			else:
				$OffsetY.value = 0
		else:
			$OffsetX.value = 0
			$OffsetY.value = 0
		
		if asset_path.has('scale_multiplier'): $Scale.value = asset_path['scale_multiplier']
		else: $Scale.value = 1.0
	else:
		var time: float
		if Global.snapping_allowed: time = Global.get_timestamp_snapped()
		else: time = Global.song_pos
		if time < 0: time = 0
		
		for animation in Timeline.animations_track.get_children():
			if snappedf(animation['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				if !Global.replacing_allowed:
					Events.emit_signal('notify', 'Animation Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
					return
		animation_name = asset_path
	
	Popups.reveal(Popups.ANIMATION)
