extends Node

var note_controller: Node2D
var key_controller: Control

var beat_container: Node2D
var half_container: Node2D
var third_container: Node2D
var quarter_container: Node2D
var sixth_container: Node2D
var eighth_container: Node2D

var key_beat_container: Node2D
var key_half_container: Node2D
var key_third_container: Node2D
var key_quarter_container: Node2D
var key_sixth_container: Node2D
var key_eighth_container: Node2D

var note_container: Node2D

var shutter_track: Node2D
var animations_track: Node2D
var backgrounds_track: Node2D
var modifier_track: Node2D
var sfx_track: Node2D
var oneshot_sound_track: Node2D
var voice_banks_track: Node2D

var note_scroller: Control

var inc_scale: float

var marquee_point_a: float = -1
var marquee_point_b: float = -1

func create_note(key: int):
	if not Global.project_loaded: return
	if Popups.open: return
	
	var time: float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	if time < 0: time = 0
	
	# Check Note Exists
	for note in Timeline.note_container.get_children(): if snappedf(note.data['timestamp'], 0.001) == snappedf(time, 0.001):
		if Global.replacing_allowed:
			delete_note(note, Save.notes['charts'][Global.difficulty_index]['notes'].find(note.data))
		else:
			print('Note already exists at %s' % [snappedf(note.data['timestamp'], 0.001)])
			return
	
	# Create New Note
	var new_note_data = {'input_type':key, "note_modifier":0, 'timestamp':time }
	Global.current_chart.append(new_note_data)
	Global.current_chart.sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Events.emit_signal("note_created", new_note_data)
	print('Added note ' + str(key) + ' at %s' % [snappedf(time, 0.001)])

func delete_note(note: Node2D, idx: int):
	Global.project_saved = false
	Events.emit_signal("note_deleted")
	print("Deleting note %s at %s (index %s)" % [note, note.data['timestamp'],idx])
	Global.current_chart.remove_at(idx)
	note.queue_free()

func delete_keyframe(section: String, node: Node2D, idx: int):
	if Save.keyframes[section].size() > 0:
		Global.project_saved = false
		print("Deleting %s %s at %s (index %s)" % [section, node, node.data['timestamp'],idx])
		Save.keyframes[section].remove_at(idx)
		node.queue_free()

func delete_keyframes(section: String, parent: Node):
	for child in parent.get_children(): delete_keyframe(section, child, 0)

func clamp_seek(value):
	Global.music.song_position_raw = clampf(Global.music.song_position_raw + value, 0.0, Global.song_length)
	Global.music.seek(Global.music.song_position_raw)
	Global.music.pause_pos = Global.music.song_position_raw
	note_scroller.value = Global.music.song_position_raw

func seek(value):
	Global.music.song_position_raw = value
	Global.music.seek(Global.music.song_position_raw)
	Global.music.pause_pos = Global.music.song_position_raw
	note_scroller.value = Global.music.song_position_raw

func reset():
	seek(0.0)

func clear_timeline():
	clear_notes_only()
	delete_keyframes('shutter', shutter_track)
	delete_keyframes('loops', animations_track)
	delete_keyframes('background', backgrounds_track)
	if Global.project_loaded: for child in modifier_track.get_children():
		if child.data['timestamp'] != 0: delete_keyframe('modifiers', child, 0)
	else: delete_keyframes('modifiers', modifier_track)
	delete_keyframes('sound_loop', sfx_track)
	delete_keyframes('sound_oneshot', oneshot_sound_track)
	delete_keyframes('voice_bank', voice_banks_track)

func clear_notes_only():
	print('Cleaning Notes Only')
	Global.current_chart.clear()
	for note in note_container.get_children(): note.queue_free()

func _input(event):
	if Popups.open or Global.lock_timeline: return
	
	if event.is_action_pressed("key_0"):
		create_note(Enums.NOTE.Z)
	if event.is_action_pressed("key_1"):
		create_note(Enums.NOTE.X)
	if event.is_action_pressed("key_2"):
		create_note(Enums.NOTE.C)
	if event.is_action_pressed("key_3"):
		create_note(Enums.NOTE.V)
	
	if event is InputEventMouseButton:
		if get_viewport().get_mouse_position().y > 672:
			# Zooming
			if event.is_command_or_control_pressed():
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					Global.note_speed = clampf(Global.note_speed + 10, 100, 1000)
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					Global.note_speed = clampf(Global.note_speed - 10, 100, 1000)
				Events.emit_signal('update_notespeed')
			else:
				if get_viewport().get_mouse_position().y > 872:
					# Seeking
					inc_scale = (Global.zoom_factor / 16) if !event.alt_pressed else 0.005
					if event.button_index == MOUSE_BUTTON_WHEEL_UP:
						clamp_seek(inc_scale)
					if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
						clamp_seek(-inc_scale)
					
					if event.pressed:
						match event.button_index:
							MOUSE_BUTTON_LEFT:
								if Global.current_tool == Enums.TOOL.MARQUEE:
									if marquee_point_a < 0:
										marquee_point_a = Global.music.song_position_raw
										line_center.set_default_color(Color(1,1,1,1))
					else:
						match event.button_index:
							MOUSE_BUTTON_LEFT:
								if Global.current_tool == Enums.TOOL.MARQUEE and marquee_point_a >= 0:
									marquee_point_b = Global.music.song_position_raw
									line_center.set_default_color(Color(0.61,0.02,0.26,1))
									marquee_point_a = -1
									marquee_point_b = -1
	
	if event is InputEventPanGesture:
		if get_viewport().get_mouse_position().y > 672:
			# Zooming
			if event.is_command_or_control_pressed():
				Global.note_speed = clampf(Global.note_speed + (10 * event.delta.y), 100, 1000)
				Events.emit_signal('update_notespeed')
			else:
				# Seeking
				inc_scale = (Global.zoom_factor / 8) if !event.alt_pressed else 0.005
				clamp_seek(inc_scale * event.delta.x)
	
	if event is InputEventKey:
		# Speed up / Slow down song
		if event.is_action_pressed("ui_up"):
			Global.music.pitch_scale = clampf(Global.music.pitch_scale + 0.1, 0.5, 2.0)
		if event.is_action_pressed("ui_down"):
			Global.music.pitch_scale = clampf(Global.music.pitch_scale - 0.1, 0.5, 2.0)
		
		# Seek to beginning / End
		if OS.get_name() == "macOS":
			if event.is_action_pressed("ui_end"): reset()
		else:
			if event.is_action_pressed("ui_home"): reset()
		if OS.get_name() == "macOS":
			if event.is_action_pressed("ui_home"): seek(Global.song_length)
		else:
			if event.is_action_pressed("ui_end"): seek(Global.song_length)
		
		# Fast Seek +5 AND Seek to beginning / End
		if event.is_action_pressed("ui_right"):
			if OS.get_name() == "macOS" and event.is_meta_pressed(): reset()
			else: clamp_seek(-5.0)
		if event.is_action_pressed("ui_left"):
			if OS.get_name() == "macOS" and event.is_meta_pressed(): seek(Global.song_length)
			else: clamp_seek(5.0)
