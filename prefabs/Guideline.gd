extends Line2D

var indicator_index: int
var indicator_type: int

func _ready():
	Events.update_notespeed.connect(update_position)
	Events.update_snapping.connect(_on_update_snapping)
	Events.update_bpm.connect(update_indicator)

func setup(i, type):
	indicator_index = i
	indicator_type = type
	update_position()

func update_position():
	match indicator_type:
		Enums.UI_INDICATOR_TYPE.BEAT:
			if Save.keyframes['modifiers'].size() > 1: position.x = -(indicator_index * Global.beat_length_msec - Global.offset + Global.beat_offset) * Global.note_speed
			else: position.x = -(indicator_index * Global.beat_length_msec - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.HALF_BEAT:
			if Save.keyframes['modifiers'].size() > 1: position.x = -(indicator_index * Global.beat_length_msec/2 - Global.offset + Global.beat_offset) * Global.note_speed
			else: position.x = -(indicator_index * Global.beat_length_msec/2 - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.THIRD_BEAT:
			if Save.keyframes['modifiers'].size() > 1: position.x = -(indicator_index * Global.beat_length_msec/3 - Global.offset + Global.beat_offset) * Global.note_speed
			position.x = -(indicator_index * Global.beat_length_msec/3 - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.QUARTER_BEAT:
			if Save.keyframes['modifiers'].size() > 1: position.x = -(indicator_index * Global.beat_length_msec/4 - Global.offset + Global.beat_offset) * Global.note_speed
			else: position.x = -(indicator_index * Global.beat_length_msec/4 - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.SIXTH_BEAT:
			if Save.keyframes['modifiers'].size() > 1: position.x = -(indicator_index * Global.beat_length_msec/6 - Global.offset + Global.beat_offset) * Global.note_speed
			else: position.x = -(indicator_index * Global.beat_length_msec/6 - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT:
			if Save.keyframes['modifiers'].size() > 1: position.x = -(indicator_index * Global.beat_length_msec/8 - Global.offset + Global.beat_offset) * Global.note_speed
			else: position.x = -(indicator_index * Global.beat_length_msec/8 - Global.offset) * Global.note_speed

func _on_update_snapping(index):
	# 1/3rds and 1/6ths are special cases
	if indicator_type == 1 && index == 2:
		modulate = Color(1,1,1,0)
	elif indicator_type == 3 && index == 4:
		modulate = Color(1,1,1,0)
	elif indicator_type == 2 && indicator_type != index:
		modulate = Color(1,1,1,0)
	elif index == 5 && indicator_type == 4:
		modulate = Color(1,1,1,0)
	elif index >= indicator_type:
		modulate = Color(1,1,1,1)
	else:
		modulate = Color(1,1,1,0)
	update_indicator()
	
func _process(_delta):
	visible = global_position.x >= Global.note_culling_bounds.x and global_position.x < Global.note_culling_bounds.y

func update_indicator():
	if Save.keyframes['modifiers'].size() > 1:
		var idx = Global.bpm_index; if idx < 1: idx = 1
		if idx < Save.keyframes['modifiers'].size(): if position.x < Timeline.modifier_track.get_child(idx).position.x: modulate = Color(1,1,1,0)
		else: idx = Save.keyframes['modifiers'].size()-1
