extends Panel

var path:String
var timestamp:float

# default/prev values
var Scale:float = 1.0

func _ready():
	Events.popups_opened.connect(_on_popups_opened)
	Events.add_background_to_timeline.connect(_on_add_background_to_timeline)

func _on_popups_opened(_index):
	if Popups.id > 0:
		$Label.text = "Edit Background"; $Create.text = "Edit"
	else:
		$Label.text = "Place New Background"; $Create.text = "Create"
		reset()

func _on_create_button_up():
	var time:float = 0
	
	var new_background_key = {
		"timestamp":time,
		"path":path
		}
	if $Scale/CheckBox.button_pressed: new_background_key["background_scale_multiplier"] = $Scale.value
	
	Scale = $Scale.value
	
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
	_on_cancel_button_up()

func _on_cancel_button_up():
	Popups.close()
	Popups.id = -1

func reset():
	$Scale.value = Scale

func _on_add_background_to_timeline(asset_path):
	if Popups.id > 0:
		path = asset_path['path']
		timestamp = asset_path['timestamp']
		
		if asset_path.has('background_scale_multiplier'):
			$Scale/CheckBox.button_pressed = true
			$Scale.value = asset_path['background_scale_multiplier']
		else:
			$Scale/CheckBox.button_pressed = false
	else:
		var time:float = 0
		
		for background in Timeline.backgrounds_track.get_children():
			if snappedf(background['data']['timestamp'], 0.001) == snappedf(time, 0.001):
				if !Global.replacing_allowed:
					Events.emit_signal('notify', 'Background Already Exists', 'Timestamp: ' + str(snappedf(time, 0.001)))
					return
		path = asset_path
	_on_check_box_button_up()
	Popups.reveal(Popups.BACKGROUND)

func _on_check_box_button_up():
	$Scale.editable = $Scale/CheckBox.button_pressed
