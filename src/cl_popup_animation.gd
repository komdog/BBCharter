extends Panel

var animation_name:String
var timestamp:float

# default/prev values
var Horny:String = ""
var SheetH:int = 2
var SheetV:int = 3
var Total:int = 6
var OffsetX:int = 0
var OffsetY:int = 0
var Scale:float = 1.0

func _ready():
	Events.popups_opened.connect(_on_popups_opened)
	Events.add_animation_to_timeline.connect(_on_add_animation_to_timeline)

func _on_popups_opened(_index):
	if Popups.id > 0:
		$Label.text = "Edit Animation"; $Create.text = "Edit"
	else:
		$Label.text = "Place New Animation"; $Create.text = "Create"
		reset()

func _on_create_button_up():
	var time:float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	if time < 0: time = 0
	
	var new_animation_key = {
		"timestamp": time,
		"sheet_data": {"h": $SheetH.value, "v": $SheetV.value, "total": $Total.value},
		"animations": {
			"normal": animation_name,
			"horny": $Horny.text if $Horny.text != "" else animation_name
			}
		}
	if $OffsetX/CheckBox.button_pressed: new_animation_key["position_offset"] = {"x": $OffsetX.value ,"y": $OffsetY.value}
	if $Scale/CheckBox.button_pressed: new_animation_key["scale_multiplier"] = $Scale.value
	
	Horny = $Horny.text
	SheetH = $SheetH.value
	SheetV = $SheetV.value
	Total = $Total.value
	OffsetX = $OffsetX.value
	OffsetY = $OffsetY.value
	Scale = $Scale.value
	
	if Popups.id > 0 or Global.replacing_allowed:
		if Popups.id > 0:
			time = timestamp; new_animation_key['timestamp'] = time
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

func reset():
	$Horny.text = Horny
	$SheetH.value = SheetH
	$SheetV.value = SheetV
	$Total.value = Total
	$OffsetX.value = OffsetX
	$OffsetY.value = OffsetY
	$Scale.value = Scale

func _on_add_animation_to_timeline(asset_path):
	if Popups.id > 0:
		animation_name = asset_path['animations']['normal']
		timestamp = asset_path['timestamp']
		$SheetH.value = asset_path['sheet_data']['h']
		$SheetV.value = asset_path['sheet_data']['v']
		$Total.value = asset_path['sheet_data']['total']
		
		if asset_path['animations'].has('horny') and asset_path['animations']['horny'] != animation_name:
			$Horny.text = asset_path['animations']['horny']
		else:
			$Horny.text = ""
		
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
	else:
		var time:float
		if Global.snapping_allowed: time = Global.get_timestamp_snapped()
		else: time = Global.song_pos
		if time < 0: time = 0
		
		for animation in Timeline.animations_track.get_children():
			if snappedf(animation['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				if !Global.replacing_allowed:
					Events.emit_signal('notify', 'Animation Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
					return
		animation_name = asset_path
	_on_check_box_button_up()
	Popups.reveal(Popups.ANIMATION)

func _on_check_box_button_up():
	$OffsetX.editable = $OffsetX/CheckBox.button_pressed
	$OffsetY.editable = $OffsetX/CheckBox.button_pressed
	$Scale.editable = $Scale/CheckBox.button_pressed
