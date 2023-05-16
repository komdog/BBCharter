extends Node2D

var init_scale: Vector2
var total_sprite_frames: float
var animation_time: float
var manual_speed_multiplier: float

var horny: bool
var horny_notes: Array

var loop_index: int
var last_loop_index: int

var current_note_timestamp
var next_note_timestamp
var tween

func _ready() -> void:
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.hit_note.connect(_on_hit_note)
	Events.miss_note.connect(_on_miss_note)

	
func _on_chart_loaded():
	loop_index = 0
	change_animation(loop_index)
	horny = false
	horny_notes = []


func _physics_process(_delta):
	if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0:
		var arr = Save.keyframes['loops'].filter(func(loop): return Global.get_synced_song_pos() >= loop['timestamp'])
		loop_index = arr.size()
		if loop_index != last_loop_index:
			last_loop_index = loop_index
			change_animation(loop_index-1)
		if Global.get_synced_song_pos() < Save.keyframes['loops'][0]['timestamp']:
			change_animation(loop_index-1)
	else:
		$Visual.texture = null
		$Visual.hframes = 1
		$Visual.vframes = 1
		$Visual.frame = 0



func change_animation(idx: int) -> void:
	
	if idx < 0: idx = 0
	if Save.keyframes['loops'].size() <= 0: return
		
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

	$Visual.hframes = loop['sheet_data']["h"] # Get hframes from preset
	$Visual.vframes = loop['sheet_data']["v"] # Get vframes from preset
	total_sprite_frames = loop['sheet_data']["total"]
	if Global.get_synced_song_pos() >= Save.keyframes['loops'][0]['timestamp']: run_loop()


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

	if horny_notes.has(index):
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
