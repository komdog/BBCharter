extends Node2D

var data: Dictionary
var beat: float

var move_pos: bool
var mouse_pos: float
var mouse_pos_start: float
var mouse_pos_end: float
var selected_key: Node2D

func _ready():
	Events.update_notespeed.connect(update_position)

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Global.snapping_allowed: mouse_pos = Global.get_mouse_timestamp_snapped()
		else: mouse_pos = Global.get_mouse_timestamp()
		if mouse_pos < 0: mouse_pos = 0
		
		if move_pos and selected_key != null:
			selected_key.update_beat_and_position(mouse_pos)
			Save.keyframes['background'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])

func setup(keyframe_data):
	move_pos = false
	data = keyframe_data
	beat = Global.get_beat_at_time(data['timestamp'])
	$InputHandler.tooltip_text = data['path']
	$Thumb.texture = Assets.get_asset(data['path'])
	if $Thumb.texture:
		$Thumb.texture_filter = TEXTURE_FILTER_LINEAR
		var frame_size = $Thumb.texture.get_size()
		var ratio = 104
		scale = Vector2(ratio,ratio)/frame_size
		$InputHandler.size = frame_size
		$InputHandler.position = -$InputHandler.size/2
		update_position()

func update_position():
	data['timestamp'] = Global.get_time_at_beat(beat)
	position.x = -((data['timestamp'] - Global.offset) * Global.note_speed)

func update_beat_and_position(time: float):
	beat = Global.get_beat_at_time(time)
	data['timestamp'] = time
	position.x = -((data['timestamp'] - Global.offset) * Global.note_speed)

func _on_input_handler_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					selected_key = self
					mouse_pos_start = self['data']['timestamp']
					if event.double_click:
						Popups.id = 1
						Events.emit_signal('add_background_to_timeline', data)
				MOUSE_BUTTON_MIDDLE:
					print(Save.keyframes['background'].find(data))
				MOUSE_BUTTON_RIGHT:
					Global.project_saved = false
					Timeline.delete_keyframe('background', self, Save.keyframes['background'].find(data))
		else:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					mouse_pos_end = mouse_pos
					for key in Timeline.backgrounds_track.get_children(): if key != selected_key: if snappedf(key['data']['timestamp'], 0.001) == snappedf(selected_key['data']['timestamp'], 0.001):
						if Global.replacing_allowed:
							Timeline.delete_keyframe('background', key, Save.keyframes['background'].find(key['data']))
						else:
							print('Background already exists at %s' % [snappedf(mouse_pos_end, 0.001)])
							selected_key.update_beat_and_position(mouse_pos_start)
							break
					Save.keyframes['background'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp']); update_position()
					if mouse_pos_start != selected_key['data']['timestamp']: Global.project_saved = false
					selected_key = null; mouse_pos_start = 0; mouse_pos_end = 0; move_pos = false

func _on_mouse_exited():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): move_pos = true
