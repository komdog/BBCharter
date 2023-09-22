extends Line2D

var indicator_index: int
var indicator_type: int

func _ready():
	Events.update_notespeed.connect(update_position)
	Events.update_snapping.connect(_on_update_snapping)
	Events.update_bpm.connect(update_position)

func setup(i, type):
	indicator_index = i
	indicator_type = type
	update_position()

func update_position():
	match indicator_type:
		Enums.UI_INDICATOR_TYPE.BEAT:
			position.x = -(Global.get_time_at_beat(indicator_index) - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.HALF_BEAT:
			position.x = -(Global.get_time_at_beat(indicator_index/2.0) - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.THIRD_BEAT:
			position.x = -(Global.get_time_at_beat(indicator_index/3.0) - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.QUARTER_BEAT:
			position.x = -(Global.get_time_at_beat(indicator_index/4.0) - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.SIXTH_BEAT:
			position.x = -(Global.get_time_at_beat(indicator_index/6.0) - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT:
			position.x = -(Global.get_time_at_beat(indicator_index/8.0) - Global.offset) * Global.note_speed

func _on_update_snapping(index):
	# 1/3rds and 1/6ths are special cases
	if indicator_type == Enums.UI_INDICATOR_TYPE.HALF_BEAT and index == 2:
		modulate = Color(1,1,1,0)
	elif indicator_type == Enums.UI_INDICATOR_TYPE.QUARTER_BEAT and index == 4:
		modulate = Color(1,1,1,0)
	elif indicator_type == Enums.UI_INDICATOR_TYPE.THIRD_BEAT and (index == 3 or index == 5):
		modulate = Color(1,1,1,0)
	elif indicator_type == Enums.UI_INDICATOR_TYPE.SIXTH_BEAT and index == 5:
		modulate = Color(1,1,1,0)
	elif index >= indicator_type:
		modulate = Color(1,1,1,1)
	else:
		modulate = Color(1,1,1,0)

func _process(_delta):
	visible = global_position.x >= Global.note_culling_bounds.x and global_position.x < Global.note_culling_bounds.y
