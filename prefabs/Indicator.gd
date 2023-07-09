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
	var point_0 = get("points")[0]
	var point_1 = get("points")[1]
	match type:
		Enums.UI_INDICATOR_TYPE.BEAT:
			default_color = Color(1,1,1,1)
			$BeatNum.text = str(i)
			$BeatNum.show()
		Enums.UI_INDICATOR_TYPE.HALF_BEAT:
			set("points", [point_0 * 0.8, point_1 * 0.8])
			default_color = Color(1,1,1,0.5)
		Enums.UI_INDICATOR_TYPE.THIRD_BEAT:
			set("points", [point_0 * 0.7, point_1 * 0.7])
			default_color = Color(0.8,1,0.8,0.4)
		Enums.UI_INDICATOR_TYPE.QUARTER_BEAT:
			set("points", [point_0 * 0.6, point_1 * 0.6])
			default_color = Color(1,1,1,0.25)
		Enums.UI_INDICATOR_TYPE.SIXTH_BEAT:
			set("points", [point_0 * 0.5, point_1 * 0.5])
			default_color = Color(0.8,1,0.8,0.25)
		Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT:
			set("points", [point_0 * 0.4, point_1 * 0.4])
			default_color = Color(1,0,0,0.25)
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
