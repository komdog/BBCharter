extends Node2D

var init_scale: Vector2
var total_sprite_frames: float
var animation_time: float
var manual_speed_multiplier: float

var horny: bool
var horny_notes: Array

var loop_index: int
var last_loop_index: int

var bg_index: int
var last_bg_index: int
var bg_type: int

var current_note_timestamp
var next_note_timestamp
var tween

func _ready() -> void:
	Events.project_loaded.connect(_on_project_loaded)
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.popups_closed.connect(_on_popups_closed)
	Events.hit_note.connect(_on_hit_note)
	Events.miss_note.connect(_on_miss_note)
	Events.tool_used_before.connect(_on_tool_used_before)
	Events.tool_used_after.connect(_on_tool_used_after)

func _on_project_loaded():
	if Save.settings.has('background_type'):
		bg_type = Save.settings['background_type']
		if bg_type == 0:
			$Pattern.visible = true; $Static.visible = false
		else:
			$Pattern.visible = false; $Static.visible = true
	else:
		$Pattern.visible = true; $Static.visible = false

func _on_chart_loaded():
	horny = false
	horny_notes = []
	loop_index = 0
	change_animation(loop_index)
	$Visual.frame = total_sprite_frames-1

func _physics_process(_delta):
	if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0 and Timeline.animations_track.get_child_count() > 0 and Global.project_loaded:
		var arr = Save.keyframes['loops'].filter(func(loop): return Global.get_synced_song_pos() > loop['timestamp'])
		loop_index = arr.size()
		if loop_index != last_loop_index:
			last_loop_index = loop_index
			change_animation(loop_index-1)
		if Global.get_synced_song_pos() <= Save.keyframes['loops'][0]['timestamp']:
			change_animation(loop_index-1)
	else:
		if Global.project_loaded:
			$Visual.texture = null
			$Visual.hframes = 1
			$Visual.vframes = 1
			$Visual.frame = $Visual.hframes * $Visual.vframes - 1
	
	if Save.keyframes.has('background') and Save.keyframes['background'].size() > 0 and Global.project_loaded:
		var arr = Save.keyframes['background'].filter(func(bg): return Global.get_synced_song_pos() > bg['timestamp'])
		bg_index = arr.size()
		if bg_index != last_bg_index:
			last_bg_index = bg_index
			change_background(bg_index-1)
		if Global.get_synced_song_pos() <= Save.keyframes['background'][0]['timestamp']:
			change_background(loop_index-1)
	else:
		if Global.project_loaded:
			$Pattern.texture = preload("res://assets/Pattern.png")

func _on_tool_used_before(data):
	if Global.current_tool == Enums.TOOL.HORNY:
		if data.has('horny') and data['horny'].has('required'):
			var index = Global.current_chart.find(data)
			var notes_left = 0
			if data['horny']['required'] - 1 > 0:
				notes_left = data['horny']['required'] - 1
			if horny_notes.has(index + notes_left):
				horny_notes.remove_at(horny_notes.find(index + notes_left))

func _on_tool_used_after(data):
	if Global.current_tool == Enums.TOOL.HORNY:
		var idx
		var index = Global.current_chart.find(data)
		if data.has('horny') and data['horny'].has('required'):
			var notes_left = 0
			if data['horny']['required'] - 1 > 0:
				notes_left = data['horny']['required'] - 1
			if !horny_notes.has(index + notes_left):
				horny_notes.append(index + notes_left)
			idx = index + notes_left
		else:
			idx = index
		
		if Global.current_chart.size() > idx and Global.get_synced_song_pos() >= Global.current_chart[idx]['timestamp']:
			for i in horny_notes.size():
				if horny_notes.size() > 1 and !i-1 < 0:
					if idx >= horny_notes[i] and idx < horny_notes[i-1]:
						horny = true
						Events.emit_signal('horny_mode')
						break
					else:
						horny = false
				else:
					if idx >= horny_notes[i]:
						horny = true
						Events.emit_signal('horny_mode')
						break
					else:
						horny = false
			
			if Save.keyframes['loops'].is_empty():
				return
			else:
				var old = $Visual.texture
				var loop = Save.keyframes['loops'][loop_index-1]
				if horny_notes.has(idx):
					$Visual.texture = Assets.get_asset(loop['animations']['horny'])
					horny = true
					Events.emit_signal('horny_mode')
					if old != $Visual.texture:
						run_loop()
				else:
					$Visual.texture = Assets.get_asset(loop['animations']['normal'])
					horny = false
					if old != $Visual.texture:
						run_loop()

func set_animation(idx: int) -> void:
	if idx < 0: idx = 0
	if !Save.keyframes.has('loops') or Save.keyframes['loops'].size() <= 0: return
	var loop = Save.keyframes['loops'][idx]
	
	# Change Texture
	if horny:
		$Visual.texture = Assets.get_asset(loop['animations']['horny'])
	else:
		$Visual.texture = Assets.get_asset(loop['animations']['normal'])
	
	if loop.has('manual_speed_multiplier'):
		manual_speed_multiplier = loop['manual_speed_multiplier']
	else:
		if idx == 0:
			manual_speed_multiplier = 1
	
	if loop.has('scale_multiplier'):
		$Visual.scale = Vector2(loop['scale_multiplier'], loop['scale_multiplier'])
	else:
		if idx == 0:
			$Visual.scale = Vector2(1, 1)
	
	if loop.has('position_offset'):
		if loop['position_offset'].has('x'):
			$Visual.offset.x = loop['position_offset']['x']/2
		else:
			$Visual.offset.x = 0
		if loop['position_offset'].has('y'):
			$Visual.offset.y = loop['position_offset']['y']/2
		else:
			$Visual.offset.y = 0
	else:
		if idx == 0:
			$Visual.offset = Vector2(0, 0)
	
	$Visual.hframes = loop['sheet_data']["h"] # Get hframes from preset
	$Visual.vframes = loop['sheet_data']["v"] # Get vframes from preset
	total_sprite_frames = loop['sheet_data']["total"]

func change_animation(idx: int) -> void:
	set_animation(idx)
	if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0:
		if Global.get_synced_song_pos() > Save.keyframes['loops'][0]['timestamp']: run_loop()

func _on_hit_note(data) -> void:
	# Ignore Ghost Notes
	if data['note_modifier'] == 2: return
	var index = Global.current_chart.find(data)
	
	if data.has('horny') and data['horny'].has('required'):
		var notes_left = 0
		if data['horny']['required'] - 1 > 0:
			notes_left = data['horny']['required'] - 1
		if !horny_notes.has(index + notes_left):
			horny_notes.append(index + notes_left)
	
	if horny_notes.has(index):
		$Visual.texture = Assets.get_asset(Save.keyframes['loops'][loop_index-1]['animations']['horny'])
		horny = true
		Events.emit_signal('horny_mode')
	else:
		horny = false
	
	current_note_timestamp = Global.current_chart[index]['timestamp']
	if index < Global.current_chart.size()-1:
		next_note_timestamp = Global.current_chart[index + 1]['timestamp']
	if !next_note_timestamp: return
	
	animation_time = (next_note_timestamp - current_note_timestamp) / manual_speed_multiplier
	
	print("index: ", index, " : ", total_sprite_frames)
	run_loop()

func _on_miss_note(data) -> void:
	var loop
	if !loop_index-1 < 0:
		loop = Save.keyframes['loops'][loop_index-1]
	var index = Global.current_chart.find(data)
	
	var old = horny
	for i in horny_notes.size():
		if horny_notes.size() > 1 and !i-1 < 0:
			if index >= horny_notes[i] and index < horny_notes[i-1]:
				horny = true
				break
			else:
				horny = false
		else:
			if index >= horny_notes[i]:
				horny = true
				break
			else:
				horny = false
	if old != horny:
		change_animation(loop_index-1)
	
	if horny_notes.has(index) and horny:
		$Visual.texture = Assets.get_asset(loop['animations']['normal'])
		run_loop()
		horny = false

func run_loop():
	$Visual.frame = 0
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	tween.tween_property($Visual, "frame", total_sprite_frames-1, animation_time / Global.music.pitch_scale)
	tween.play()

func change_background(idx: int) -> void:
	if idx < 0: idx = 0
	if Save.keyframes['background'].size() <= 0: return
	var bg = Save.keyframes['background'][idx]
	
	# Change Texture
	if bg_type == 0:
		$Pattern.texture = Assets.get_asset(bg['path'])
	else:
		$Static.texture = Assets.get_asset(bg['path'])
	
	if bg.has('background_scale_multiplier'):
		if bg_type == 0:
			$Pattern.scale = Vector2(bg['background_scale_multiplier'] * 0.278, bg['background_scale_multiplier'] * 0.281)
		else:
			$Static.scale = Vector2(bg['background_scale_multiplier'] * 2/3, bg['background_scale_multiplier'] * 2/3)
	else:
		if idx == 0:
			$Pattern.scale = Vector2(0.278, 0.281)
		else:
			$Static.scale = Vector2(2/3, 2/3)

func _on_popups_closed():
	set_animation(loop_index-1)

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			Popups.type = 1
			var data
			if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0:
				data = Save.keyframes['loops'][loop_index-1]
				if Global.get_synced_song_pos() <= Save.keyframes['loops'][0]['timestamp']:
					data = Save.keyframes['loops'][0]
				Events.emit_signal('add_animation_to_timeline', data)
