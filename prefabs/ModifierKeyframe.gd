extends Node2D

var data: Dictionary

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
			selected_key['data']['timestamp'] = mouse_pos
			Save.keyframes['modifiers'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			update_position()

func setup(keyframe_data):
	move_pos = false
	data = keyframe_data
	$InputHandler.tooltip_text = str(data['bpm'])
	update_position()

func update_position():
	position.x = -((data['timestamp'] - Global.offset - Global.bpm_offset) * Global.note_speed)

func _on_input_handler_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					selected_key = self
					if event.double_click:
						Global.lock_timeline = true
						$Visual.visible = false
						$InputHandler.visible = false
						$LineEdit.visible = true
						$LineEdit.text = str(data['bpm'])
				MOUSE_BUTTON_MIDDLE:
					print(Save.keyframes['modifiers'].find(data))
				MOUSE_BUTTON_RIGHT:
					if data['timestamp'] != 0:
						Timeline.delete_keyframe('modifiers', self, Save.keyframes['modifiers'].find(data))
						if Save.keyframes['modifiers'].size() <= 1: Global.beat_offset = 0
						Global.reload_bpm(Global.bpm_index)
						Global.project_saved = false
					else:
						print('This modifier is used to set Global.bpm')
		else:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if selected_key != null:
						mouse_pos_end = mouse_pos
						for key in Timeline.modifier_track.get_children(): if key != selected_key: if snappedf(key['data']['timestamp'], 0.001) == snappedf(selected_key['data']['timestamp'], 0.001):
							if Global.replacing_allowed:
								Timeline.delete_keyframe('modifiers', key, Save.keyframes['modifiers'].find(key['data']))
							else:
								print('Modifier already exists at %s' % [snappedf(mouse_pos_end, 0.001)])
								selected_key['data']['timestamp'] = mouse_pos_start
								break
						Save.keyframes['modifiers'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp']); update_position()
						if mouse_pos_start != selected_key['data']['timestamp']: Global.project_saved = false
						selected_key = null; mouse_pos_start = 0; mouse_pos_end = 0; move_pos = false

func _input(event):
	if $LineEdit.visible and event is InputEventMouseButton and event.pressed:
		if (get_window().get_mouse_position().x < $LineEdit.global_position.x
		or get_window().get_mouse_position().x > $LineEdit.global_position.x + $LineEdit.size.x
		or get_window().get_mouse_position().y < $LineEdit.global_position.y
		or get_window().get_mouse_position().y > $LineEdit.global_position.y + $LineEdit.size.y):
			$Visual.visible = true
			$InputHandler.visible = true
			$LineEdit.visible = false
			_on_text_submitted($LineEdit.text)
			Global.lock_timeline = false

func _on_text_submitted(new_text):
	if new_text.to_float() != data['bpm']:
		if new_text.to_float() < 60:
			new_text = '60'
			$LineEdit.text = '60'
		if new_text.to_float() > 300:
			new_text = '300'
			$LineEdit.text = '300'
		
		$InputHandler.tooltip_text = new_text
		Save.keyframes['modifiers'][Save.keyframes['modifiers'].find(data)]['bpm'] = float(new_text)
		data['bpm'] = float(new_text)
		if data['timestamp'] == 0: Global.global_bpm = data['bpm']
		
		var idx = Global.bpm_index-1; if idx < 0: idx = 0
		Global.bpm = Save.keyframes['modifiers'][idx]['bpm']
		Global.bpm_offset = Save.keyframes['modifiers'][idx]['timestamp']
		var bpm = Save.keyframes['modifiers'][idx-1]['bpm']; var time = Save.keyframes['modifiers'][idx-1]['timestamp']
		Global.beat_offset = (float(60.0/Global.bpm)-Global.bpm_offset) + (float(60.0/bpm)-time/(60.0/bpm))
		if Global.beat_offset < 0: Global.beat_offset = 0
		Global.reload_bpm(idx)
		
		Global.project_saved = false

func _on_mouse_exited():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if selected_key['data']['timestamp'] != 0:
			move_pos = true
		else:
			selected_key = null
			print('This modifier is used to set Global.bpm')
