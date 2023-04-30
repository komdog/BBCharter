extends Node2D

var init_scale: Vector2
# var starting_anim_index = -1
var total_sprite_frames: float
var animation_time: float
var manual_speed_multiplier: float

var loop_index: int
var last_loop_index: int

var current_note_timestamp
var next_note_timestamp
var tween

func _ready() -> void:
#	if Events.connect('horny_mode',self,'_on_horny_mode') == OK: pass
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.hit_note.connect(_on_hit_note)
	

	
func _on_chart_loaded():
	loop_index = 0
	change_animation(loop_index)


func _physics_process(_delta):
	if Save.keyframes.has('loops') and Save.keyframes['loops'].size() > 0:
		var arr = Save.keyframes['loops'].filter(func(loop): return Global.get_synced_song_pos() > loop['timestamp'])
		loop_index = arr.size()
		if loop_index != last_loop_index:
			last_loop_index = loop_index
			change_animation(loop_index-1)



func change_animation(idx: int) -> void:
	
	if idx < 0: return
	if Save.keyframes['loops'].size() <= 0: return
		
	var loop = Save.keyframes['loops'][idx]
#	Game.stats['horny_notes_required'] = -1

	# Change Texture
	$Visual.texture = Assets.get_asset(loop['animations']['normal'])
	$Visual.hframes = loop['sheet_data']["h"] # Get hframes from preset
	$Visual.vframes = loop['sheet_data']["v"] # Get vframes from preset
	total_sprite_frames = loop['sheet_data']["total"]
	run_loop()

	# Set Scale
#	if Config.field_valid(loop, 'scale_multiplier') == OK:
#		Game.stats['scale_multiplier'] = loop['scale_multiplier']

	# Set Scale
#	if Config.field_valid(loop, 'position_offset') == OK:
#		position =  Vector2(960,540) + Vector2(loop['position_offset'].x, loop['position_offset'].y)
#	else:
#		position = Vector2(960,540)
#

	# Set Speed Multiplier
#	if Config.field_valid(loop, 'manual_speed_multiplier') == OK:
#		Game.stats['manual_speed_multiplier'] = loop['manual_speed_multiplier']


#func _on_horny_mode() -> void:
#	texture = Assets.get_asset(current_animations['horny'])

func _on_hit_note(data) -> void:

	# Ignore Ghost Notes
#	if data['note_modifier'] == Enums.MODIFIER.GHOST: return
	var index = Global.current_chart.find(data)

	current_note_timestamp = Global.current_chart[index]['timestamp']

	if index < Global.current_chart.size()-1:
		next_note_timestamp = Global.current_chart[index + 1]['timestamp']

	if !next_note_timestamp: return
	
#	animation_time = (next_note_timestamp - current_note_timestamp) / Game.stats['manual_speed_multiplier']
	animation_time = (next_note_timestamp - current_note_timestamp)
	
	print("index: ", index, " : ", total_sprite_frames)
	run_loop()
	


func run_loop():
	$Visual.frame = 0
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	tween.tween_property($Visual, "frame", total_sprite_frames-1, animation_time / Global.music.pitch_scale)
	tween.play()
