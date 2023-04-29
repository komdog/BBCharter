extends Line2D

var indicator_index: int
var indicator_type: int

func _ready():
	Events.update_notespeed.connect(update_position)
	Events.update_snapping.connect(_on_update_snapping)

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
			set("points", [point_0 * 0.8, point_1 * 0.8] )
			default_color = Color(1,1,1,0.5)
		Enums.UI_INDICATOR_TYPE.QUARTER_BEAT:
			set("points", [point_0 * 0.6, point_1 * 0.6] )
			default_color = Color(1,1,1,0.25)
		Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT:
			set("points", [point_0 * 0.4, point_1 * 0.4] )
			default_color = Color(1,0,0,0.25)
			
	update_position()

func update_position():
	match indicator_type:
		Enums.UI_INDICATOR_TYPE.BEAT:
			position.x = (-(indicator_index * Global.beat_length_msec) * Global.note_speed)
		Enums.UI_INDICATOR_TYPE.HALF_BEAT:
			position.x = (-(indicator_index * Global.beat_length_msec/2) * Global.note_speed)
		Enums.UI_INDICATOR_TYPE.QUARTER_BEAT:
			position.x = (-(indicator_index * Global.beat_length_msec/4) * Global.note_speed)
		Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT:
			position.x = (-(indicator_index * Global.beat_length_msec/8) * Global.note_speed)
	
func _on_update_snapping(index):
	if index >= indicator_type:
		modulate = Color(1,1,1,1)
	else:
		modulate = Color(1,1,1,0)
	
func _process(_delta):
	visible = global_position.x >= Global.note_culling_bounds.x and global_position.x < Global.note_culling_bounds.y
