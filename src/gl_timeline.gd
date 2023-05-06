extends Node

var note_controller: Node2D

var indicator_container: Node2D
var note_container: Node2D

var animations_track: Node2D
var oneshot_sound_track: Node2D
var shutter_track: Node2D

var inc_scale: float
var note_creation_timestamp: float

func create_note(key: int):
	
	if !Global.project_loaded: return
	if Popups.open: return
	
	if Global.snapping_allowed:
		note_creation_timestamp =  Global.get_timestamp_snapped()
	else:
	
		note_creation_timestamp = Global.get_synced_song_pos()
	# Check Note Exists
	for note in Global.current_chart:
		if Global.round_to_dec(note['timestamp'], 3) == Global.round_to_dec(note_creation_timestamp, 3):
			print('Note already exists at %s' % [Global.get_synced_song_pos()])
			return
	
	# Create New Note
	var new_note_data = {'input_type':key, "note_modifier":0, 'timestamp':note_creation_timestamp }
	Global.current_chart.append(new_note_data)
	Global.current_chart.sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Events.emit_signal("note_created", new_note_data)
	
func delete_note(note: Node2D, idx: int):
	print("Deleting note %s at %s (index %s)" % [note, note.data['timestamp'],idx])
	Global.current_chart.remove_at(idx)
	note.queue_free()
	
func delete_keyframe(section: String, node: Node2D, idx: int):
	print("Deleting %s %s at %s (index %s)" % [section, node, node.data['timestamp'],idx])
	Save.keyframes[section].remove_at(idx)
	node.queue_free()

func clamp_seek(value):
	Global.music.song_position_raw = clampf(Global.music.song_position_raw + value, 0.0, Global.song_length )
	Global.music.seek(Global.music.song_position_raw)
	Global.music.pause_pos = Global.music.song_position_raw
	
func seek(value):
	Global.music.song_position_raw = value
	Global.music.seek(Global.music.song_position_raw)
	Global.music.pause_pos = Global.music.song_position_raw
	
func reset():
	seek(0.0)
	
func clear_timeline():
	Global.current_chart.clear()
	Global.clear_children(note_container)
	Global.clear_children(animations_track)
	Global.clear_children(oneshot_sound_track)
	Global.clear_children(shutter_track)
	
func clear_notes_only():
	print('Cleaning Notes Only')
	Global.current_chart.clear()
	for note in note_container.get_children():
		note.queue_free()

func _input(event):
	
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
			if Input.is_action_pressed("ui_control"):
				
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					Global.note_speed = clampf(Global.note_speed + 10, 100, 1000 )
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					Global.note_speed = clampf(Global.note_speed - 10, 100, 1000 )
					
				Events.emit_signal('update_notespeed')
				
			else:
				
			# Seeking
				inc_scale = (Global.song_beats_per_second / 8) if !Input.is_action_pressed("ui_alt") else 0.005
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					clamp_seek(inc_scale)
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					clamp_seek(-inc_scale)
			
			
	if event is InputEventKey:
		# Speed up / Slow down song	
		if event.is_action_pressed("ui_right"):
			Global.music.pitch_scale = clampf(Global.music.pitch_scale + 0.1, 0.5, 2.0 )
		if event.is_action_pressed("ui_left"):
			Global.music.pitch_scale = clampf(Global.music.pitch_scale - 0.1, 0.5, 2.0 )
			
		# Seek to beginning / End
		if event.is_action_pressed("ui_home"):
			reset()
		if event.is_action_pressed("ui_end"):
			seek(Global.song_length)
			
		# Fast Seek +10
		if event.is_action_pressed("ui_page_down"):
			clamp_seek(5.0)
		if event.is_action_pressed("ui_page_up"):
			clamp_seek(-5.0)

		
