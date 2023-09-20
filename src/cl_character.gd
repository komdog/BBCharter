extends Node2D

var init_scale: Vector2
var total_sprite_frames: float
var animation_time: float
var manual_speed_multiplier: float

var horny: bool
var notes_left: int
var horny_notes: Dictionary

var loop_index: int
var last_loop_index: int

var effect_index: int
var last_effect_index: int

var bg_index: int
var last_bg_index: int
var bg_type: int

var current_note_timestamp
var next_note_timestamp
var last_note_timestamp

var loop_tween
var effect_tween

func _ready():
	Events.song_loaded.connect(_on_song_loaded)
	Events.hit_note.connect(_on_hit_note)
	Events.miss_note.connect(_on_miss_note)
	Events.note_deleted.connect(_on_note_deleted)
	Events.tool_used_before.connect(_on_tool_used_before)
	Events.tool_used_after.connect(_on_tool_used_after)

func _on_song_loaded():
	horny = false; notes_left = -1
	horny_notes['required'] = []; horny_notes['activators'] = []; horny_notes['deactivators'] = []
	loop_index = 0; change_animation(0); $Panel/Visual.frame = total_sprite_frames-1
	effect_index = 0; last_effect_index = 0
	bg_index = 0; change_background(0)
	if Save.settings.has('background_type'):
		bg_type = Save.settings['background_type']
		$Panel/Pattern.visible = bg_type == 0; $Panel/Static.visible = bg_type == 1
	else:
		$Panel/Pattern.visible = true; $Panel/Static.visible = false

func _process(_delta):
	if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0 and Timeline.animations_track.get_child_count() > 0 and Global.project_loaded:
		var idx = loop_index-1; if idx < 0: idx = 0
		var loop = Save.keyframes['loops'][idx]
		if horny:
			if $Panel/Visual.texture != Assets.get_asset(loop['animations']['horny']):
				$Panel/Visual.texture = Assets.get_asset(loop['animations']['horny'])
				run_loop()
		else:
			if $Panel/Visual.texture != Assets.get_asset(loop['animations']['normal']):
				$Panel/Visual.texture = Assets.get_asset(loop['animations']['normal'])
				run_loop()
	
	if Save.keyframes.has('background') and Save.keyframes['background'].size() > 0 and Timeline.backgrounds_track.get_child_count() > 0 and Global.project_loaded:
		var idx = bg_index-1; if idx < 0: idx = 0
		var bg = Save.keyframes['background'][idx]
		if bg_type == 0:
			if $Panel/Pattern.texture != Assets.get_asset(bg['path']):
				$Panel/Pattern.texture = Assets.get_asset(bg['path'])
				change_background(idx)
		elif bg_type == 1:
			if $Panel/Static.texture != Assets.get_asset(bg['path']):
				$Panel/Static.texture = Assets.get_asset(bg['path'])
				change_background(idx)

func _physics_process(_delta):
	if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0 and Timeline.animations_track.get_child_count() > 0 and Global.project_loaded:
		var arr = Save.keyframes['loops'].filter(func(loop): return Global.song_pos >= loop['timestamp'])
		loop_index = arr.size()
		if loop_index != last_loop_index:
			if last_loop_index > 0:
				if loop_index - last_loop_index > 0 and horny:
					horny = false
					horny_notes['deactivators'].append(last_loop_index)
			last_loop_index = loop_index
			if horny_notes['deactivators'].has(loop_index):
				horny = true
				horny_notes['deactivators'].remove_at(horny_notes['deactivators'].find(loop_index))
			await get_tree().physics_frame
			change_animation(loop_index-1)
		if Global.song_pos < Save.keyframes['loops'][0]['timestamp']:
			horny_notes['deactivators'] = []
			change_animation(loop_index-1)
	else:
		if Global.project_loaded:
			$Panel/Visual.texture = null
			$Panel/Visual.hframes = 1
			$Panel/Visual.vframes = 1
			$Panel/Visual.frame = $Panel/Visual.hframes * $Panel/Visual.vframes - 1
	$Panel.mouse_default_cursor_shape = 2 if $Panel/Visual.texture != null else 0
	
	if Save.keyframes.has('background') and Save.keyframes['background'].size() > 0 and Global.project_loaded:
		var arr = Save.keyframes['background'].filter(func(bg): return Global.song_pos >= bg['timestamp'])
		bg_index = arr.size()
		if bg_index != last_bg_index:
			last_bg_index = bg_index
			change_background(bg_index-1)
		if Global.song_pos < Save.keyframes['background'][0]['timestamp']:
			change_background(bg_index-1)
	else:
		if Global.project_loaded:
			$Panel/Pattern.texture = preload("res://assets/Pattern.png")

func set_animation(idx: int):
	if idx < 0: idx = 0
	if !Save.keyframes.has('loops') or Save.keyframes['loops'].size() <= 0: return
	var loop = Save.keyframes['loops'][idx]
	
	# Change Texture
	if horny: $Panel/Visual.texture = Assets.get_asset(loop['animations']['horny'])
	else: $Panel/Visual.texture = Assets.get_asset(loop['animations']['normal'])
	
	for i in range(idx, -1, -1):
		if Save.keyframes['loops'][i].has('manual_speed_multiplier'):
			manual_speed_multiplier = Save.keyframes['loops'][i]['manual_speed_multiplier']
			break
		else:
			if i == 0: manual_speed_multiplier = 1
	
	for i in range(idx, -1, -1):
		if Save.keyframes['loops'][i].has('scale_multiplier'):
			$Panel/Visual.scale = Vector2(Save.keyframes['loops'][i]['scale_multiplier'], Save.keyframes['loops'][i]['scale_multiplier'])
			break
		else:
			if i == 0: $Panel/Visual.scale = Vector2(1, 1)
	
	if loop.has('position_offset'):
		if loop['position_offset'].has('x'):
			$Panel/Visual.offset.x = loop['position_offset']['x']/1.5
		else:
			$Panel/Visual.offset.x = 0
		if loop['position_offset'].has('y'):
			$Panel/Visual.offset.y = loop['position_offset']['y']/1.5
		else:
			$Panel/Visual.offset.y = 0
	else:
		if idx == 0:
			$Panel/Visual.offset = Vector2(0, 0)
	
	$Panel/Visual.hframes = loop['sheet_data']["h"] # Get hframes from preset
	$Panel/Visual.vframes = loop['sheet_data']["v"] # Get vframes from preset
	total_sprite_frames = loop['sheet_data']["total"]

func change_animation(idx: int):
	set_animation(idx)
	if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0:
		if loop_index > 1: run_loop()

func _on_hit_note(data):
	await get_tree().process_frame
	
	# Ignore Ghost Notes
	if data['note_modifier'] == 2: return
	var index = Global.current_chart.find(data)
	
	if data.has('horny') and data['horny']['required'] > 0:
		horny_notes['required'].append(index)
		notes_left = data['horny']['required']
	if notes_left > -1: notes_left -= 1
	
	if notes_left == 0:
		horny = true
		horny_notes['activators'].append(index)
		set_animation(loop_index-1)
		Events.emit_signal('horny_mode')
	
	current_note_timestamp = Global.current_chart[index]['timestamp']
	for n in range(1, Global.current_chart.size() - index):
		if Global.current_chart[index + n]['note_modifier'] != 2:
			next_note_timestamp = Global.current_chart[index + n]['timestamp']
			break
	if !next_note_timestamp: return
	
	animation_time = (next_note_timestamp - current_note_timestamp) / manual_speed_multiplier
	
	# print("index: ", index, " : ", total_sprite_frames)
	run_loop()

func _on_miss_note(data):
	# Ignore Ghost Notes
	if data['note_modifier'] == 2: return
	var index = Global.current_chart.find(data)
	
	if horny_notes['activators'].has(index):
		horny = false
		horny_notes['activators'].remove_at(horny_notes['activators'].find(index))
		set_animation(loop_index-1)
		run_loop()
		if notes_left < 0: notes_left = 0
	
	if notes_left > -1 and !horny_notes['activators'].has(index): notes_left += 1
	if data.has('horny'): notes_left = -1
	
	current_note_timestamp = Global.current_chart[index]['timestamp']
	if index > 0:
		last_note_timestamp = Global.current_chart[index - 1]['timestamp']
	if !last_note_timestamp: return
	
	animation_time = (current_note_timestamp - last_note_timestamp) / manual_speed_multiplier

func _on_note_deleted():
	for note in Timeline.note_container.get_children():
		if note['data'].has('horny'):
			if horny_notes['activators'].size() > 0:
				for a in horny_notes['activators']:
					if Global.song_pos >= Timeline.note_container.get_child(a)['data']['timestamp']:
						horny = false; notes_left = -1
						change_animation(loop_index-1)
						horny_notes['activators'].remove_at(horny_notes['activators'].find(a))
						break
			else:
				horny = false; notes_left = -1
				break

var required_old = 0
func _on_tool_used_before(note):
	if Global.current_tool == Enums.TOOL.HORNY:
		if note.has('horny'):
			required_old = note['horny']['required']

func _on_tool_used_after(note):
	if Global.current_tool == Enums.TOOL.HORNY:
		if note.has('horny'): 
			notes_left -= required_old - note['horny']['required']
			required_old = 0
			if notes_left <= 0:
				if !horny:
					horny = true
					change_animation(loop_index-1)
					Events.emit_signal('horny_mode')
					if notes_left < 0: notes_left = 0
				else:
					var idx = horny_notes['activators'].find(Global.current_chart.find(note) + required_old-1)
					horny_notes['activators'].append(Global.current_chart.find(note) + note['horny']['required']-1)
					horny_notes['activators'].remove_at(idx+1)
			elif notes_left > 0:
				if horny:
					var idx = horny_notes['activators'].find(Global.current_chart.find(note) + required_old-1)
					horny_notes['activators'].append(Global.current_chart.find(note) + note['horny']['required']-1)
					horny_notes['activators'].remove_at(idx+1)
					
					horny = false
					change_animation(loop_index-1)

func run_loop():
	$Panel/Visual.frame = 0
	if loop_tween: loop_tween.kill() # Abort the previous animation.
	loop_tween = create_tween()
	loop_tween.tween_property($Panel/Visual, "frame", total_sprite_frames-1, animation_time / Global.music.pitch_scale)
	loop_tween.play()

func change_background(idx: int):
	if idx < 0: idx = 0
	if Save.keyframes['background'].size() <= 0: return
	var bg = Save.keyframes['background'][idx]
	
	# Change Texture
	if bg_type == 0: $Panel/Pattern.texture = Assets.get_asset(bg['path'])
	else: $Panel/Static.texture = Assets.get_asset(bg['path'])
	
	if bg.has('background_scale_multiplier'):
		if bg_type == 0:
			$Panel/Pattern.scale = Vector2(bg['background_scale_multiplier'] * 0.278, bg['background_scale_multiplier'] * 0.281)
		else:
			$Panel/Static.scale = Vector2(bg['background_scale_multiplier'] * 2.0/3.0, bg['background_scale_multiplier'] * 2.0/3.0)
	else:
		if idx == 0:
			$Panel/Pattern.scale = Vector2(0.278, 0.281)
		else:
			$Panel/Static.scale = Vector2(2.0/3.0, 2.0/3.0)

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Popups.id = 1
			if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0:
				var data = Save.keyframes['loops'][loop_index-1]
				if Global.song_pos <= Save.keyframes['loops'][0]['timestamp']:
					data = Save.keyframes['loops'][0]
				Events.emit_signal('add_animation_to_timeline', data)

func _on_create_button_up():
	await get_tree().process_frame
	set_animation(loop_index-1)
