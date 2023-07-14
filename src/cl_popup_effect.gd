extends Panel

var effect_name:String
var timestamp:float

# default/prev values
var SheetH:int = 2
var SheetV:int = 3
var Total:int = 6
var Speed:float = 1.0

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
		"playback_speed": $Speed.value,
		"path": effect_name
		}
	
	SheetH = $SheetH.value
	SheetV = $SheetV.value
	Total = $Total.value
	Speed = $Speed.value
	
	if Popups.id > 0 or Global.replacing_allowed:
		if Popups.id > 0: new_effect_key['timestamp'] = timestamp
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
		$Speed.value = asset_path['playback_speed']
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
	
	Popups.reveal(Popups.EFFECT)
