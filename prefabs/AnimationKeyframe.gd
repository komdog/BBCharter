extends Node2D

var data: Dictionary
var beat: float

var move_pos: bool
var mouse_pos: float
var mouse_pos_start: float
var mouse_pos_end: float
var selected_key: Node2D

var frame_size : Vector2
var ratio = 104

func _ready():
	Events.update_notespeed.connect(update_position)

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Global.snapping_allowed: mouse_pos = Global.get_mouse_timestamp_snapped()
		else: mouse_pos = Global.get_mouse_timestamp()
		if mouse_pos < 0: mouse_pos = 0
		
		if move_pos and selected_key != null:
			selected_key.update_beat_and_position(mouse_pos)
			Save.keyframes['loops'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])

func setup(keyframe_data):
	move_pos = false
	data = keyframe_data
	beat = Global.get_beat_at_time(data['timestamp'])
	if data['animations']['normal'] == data['animations']['horny']:
		$InputHandler.tooltip_text = data['animations']['horny']
	else:
		$InputHandler.tooltip_text = data['animations']['normal'] + '\n' + data['animations']['horny']
	$Thumb.texture = Assets.get_asset(data['animations']['normal'])
	if $Thumb.texture:
		$Thumb.hframes = data['sheet_data']["h"] # Get hframes from preset
		$Thumb.vframes = data['sheet_data']["v"] # Get vframes from preset
		$Thumb.texture_filter = TEXTURE_FILTER_LINEAR
		frame_size = $Thumb.texture.get_size() / Vector2($Thumb.hframes, $Thumb.vframes)
		scale = Vector2(ratio * 1.777,ratio)/frame_size
		$InputHandler.size = frame_size
		$InputHandler.position = -$InputHandler.size/2
		update_position()
	$Thumb.offset = Vector2(-$Thumb.get_rect().size.x, -$Thumb.get_rect().size.y / 2)
	$Background.size = $Thumb.get_rect().size
	$InputHandler.size = $Thumb.get_rect().size
	$InputHandler.position = Vector2(-$InputHandler.get_rect().size.x, -$InputHandler.get_rect().size.y / 2)
	$Background.position = Vector2(-$Background.get_rect().size.x, -$Background.get_rect().size.y / 2)
	$Background.color = Color(randf(), randf(), randf(), 0.3)


func update_position():
	data['timestamp'] = Global.get_time_at_beat(beat)
	position.x = -((data['timestamp'] - Global.offset) * Global.note_speed)
	update_visuals()

func update_beat_and_position(time: float):
	beat = Global.get_beat_at_time(time)
	data['timestamp'] = time
	position.x = -((data['timestamp'] - Global.offset) * Global.note_speed)
	update_visuals()

func update_visuals():
	var ref_bg
	var ref_bg_next
	for x in Timeline.animations_track.get_children().size():
		if x+1 == Timeline.animations_track.get_children().size():
			break
		ref_bg = Timeline.animations_track.get_children()[x].get_node("Background")
		ref_bg_next = Timeline.animations_track.get_children()[x+1].get_node("Background")
		
		ref_bg.size = Timeline.animations_track.get_children()[x].get_node("Thumb").get_rect().size
		ref_bg.position = Vector2(-ref_bg.size.x, -ref_bg.size.y / 2) ## Reset size and pos
		
		print("Pref: ", x, " : ", ref_bg.size, ref_bg.position)
		ref_bg.size.x = abs(ref_bg_next.position.x) * frame_size.x
		ref_bg.position.x = -ref_bg.size.x
		print("After: ",  x, " : ", ref_bg.size, ref_bg.position)
		pass

func _on_input_handler_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					selected_key = self
					mouse_pos_start = self['data']['timestamp']
					if event.double_click:
						Popups.id = 1
						Events.emit_signal('add_animation_to_timeline', data)
				MOUSE_BUTTON_MIDDLE:
					print(Save.keyframes['loops'].find(data))
				MOUSE_BUTTON_RIGHT:
					Global.project_saved = false
					Timeline.delete_keyframe('loops', self, Save.keyframes['loops'].find(data))
		else:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					mouse_pos_end = mouse_pos
					for key in Timeline.animations_track.get_children(): if key != selected_key: if snappedf(key['data']['timestamp'], 0.001) == snappedf(selected_key['data']['timestamp'], 0.001):
						if Global.replacing_allowed:
							Timeline.delete_keyframe('loops', key, Save.keyframes['loops'].find(key['data']))
						else:
							print('Animation already exists at %s' % [snappedf(mouse_pos_end, 0.001)])
							selected_key.update_beat_and_position(mouse_pos_start)
							break
					Save.keyframes['loops'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp']); update_position()
					if mouse_pos_start != selected_key['data']['timestamp']: Global.project_saved = false
					selected_key = null; mouse_pos_start = 0; mouse_pos_end = 0; move_pos = false

func _on_mouse_exited():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): move_pos = true
