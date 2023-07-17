extends Panel

var effect_name:String
var timestamp:float

# default/prev values
var SheetH:int = 2
var SheetV:int = 3
var Total:int = 6
var Duration:float = 1.0
var Speed:float = 1.0
var OffsetX:int = 1
var OffsetY:int = 1
var Scale:float = 1.0
var Scale2:bool = false

func _ready():
	Events.popups_opened.connect(_on_popups_opened)
	Events.add_effect_to_timeline.connect(_on_add_effect_to_timeline)

func _on_popups_opened(_index):
	if Popups.id > 0:
		$Label.text = "Edit Effect"; $Create.text = "Edit"
	else:
		$Label.text = "Place New Effect"; $Create.text = "Create"
		reset()

func _on_create_button_up():
	var time:float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	
	var new_effect_key = {
		"timestamp": time,
		"sheet_data": {"h": $SheetH.value, "v": $SheetV.value, "total": $Total.value},
		"duration": $Time.value,
		"path": effect_name
		}
	if $Speed/CheckBox.button_pressed: new_effect_key["playback_speed"] = $Speed.value
	if $OffsetX/CheckBox.button_pressed: new_effect_key["position_offset"] = {"x": $OffsetX.value ,"y": $OffsetY.value}
	if $Scale/CheckBox.button_pressed: new_effect_key["scale_multiplier"] = $Scale.value
	if $Scale2/CheckBox.button_pressed: new_effect_key["character_scaled"] = $Scale2.button_pressed
	
	SheetH = $SheetH.value
	SheetV = $SheetV.value
	Total = $Total.value
	Duration = $Time.value
	Speed = $Speed.value
	OffsetX = $OffsetX.value
	OffsetY = $OffsetY.value
	Scale = $Scale.value
	Scale2 = $Scale2.button_pressed
	
	if Popups.id > 0 or Global.replacing_allowed:
		if Popups.id > 0:
			time = timestamp; new_effect_key['timestamp'] = time
		for effect in Timeline.effects_track.get_children():
			if snappedf(effect['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				Timeline.delete_keyframe('effects', effect, Save.keyframes['effects'].find(effect['data']))
	
	Global.project_saved = false
	Save.keyframes['effects'].append(new_effect_key)
	Save.keyframes['effects'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Timeline.key_controller.spawn_single_keyframe(new_effect_key, Prefabs.effect_keyframe, Timeline.effects_track)
	_on_cancel_button_up()

func _on_cancel_button_up():
	Popups.close()
	Popups.id = -1

func reset():
	$SheetH.value = SheetH
	$SheetV.value = SheetV
	$Total.value = Total
	$Speed.value = Speed

func _on_add_effect_to_timeline(asset_path):
	if Popups.id > 0:
		effect_name = asset_path['path']
		timestamp = asset_path['timestamp']
		$SheetH.value = asset_path['sheet_data']['h']
		$SheetV.value = asset_path['sheet_data']['v']
		$Total.value = asset_path['sheet_data']['total']
		$Time.value = asset_path['duration']
		if asset_path.has('playback_speed'):
			$Speed/CheckBox.button_pressed = true
			$Speed.value = asset_path['playback_speed']
		else:
			$Speed/CheckBox.button_pressed = false
		if asset_path.has('position_offset'):
			$OffsetX/CheckBox.button_pressed = true
			$OffsetX.value = asset_path['position_offset'].x; $OffsetY.value = asset_path['position_offset'].y
		else:
			$OffsetX/CheckBox.button_pressed = false
		if asset_path.has('scale_multiplier'):
			$Scale/CheckBox.button_pressed = true
			$Scale.value = asset_path['scale_multiplier']
		else:
			$Scale/CheckBox.button_pressed = false
		if asset_path.has('character_scaled'):
			$Scale2/CheckBox.button_pressed = true
			$Scale2.button_pressed = asset_path['character_scaled']
		else:
			$Scale2/CheckBox.button_pressed = false
	else:
		var time:float
		if Global.snapping_allowed: time = Global.get_timestamp_snapped()
		else: time = Global.song_pos
		
		for effect in Timeline.effects_track.get_children():
			if snappedf(effect['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				if !Global.replacing_allowed:
					Events.emit_signal('notify', 'Effect Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
					return
		effect_name = asset_path
	_on_check_box_button_up()
	Popups.reveal(Popups.EFFECT)

func _on_check_box_button_up():
	$Speed.editable = $Speed/CheckBox.button_pressed
	$OffsetX.editable = $OffsetX/CheckBox.button_pressed
	$OffsetY.editable = $OffsetX/CheckBox.button_pressed
	$Scale.editable = $Scale/CheckBox.button_pressed
	$Scale2.disabled = !$Scale2/CheckBox.button_pressed
