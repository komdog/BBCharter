extends Line2D

var indicator_index: int
var indicator_type: int

func _ready():
	Events.update_notespeed.connect(update_position)
	Events.update_snapping.connect(_on_update_snapping)

func setup(i, type):
	indicator_index = i
	indicator_type = type
	update_position()

func update_position():
	match indicator_type:
		Enums.UI_INDICATOR_TYPE.BEAT:
			position.x = -(indicator_index * Global.beat_length_msec - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.HALF_BEAT:
			position.x = -(indicator_index * Global.beat_length_msec/2 - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.QUARTER_BEAT:
			position.x = -(indicator_index * Global.beat_length_msec/4 - Global.offset) * Global.note_speed
		Enums.UI_INDICATOR_TYPE.EIGHTH_BEAT:
			position.x = -(indicator_index * Global.beat_length_msec/8 - Global.offset) * Global.note_speed
	
func _on_update_snapping(index):
	if index >= indicator_type:
		modulate = Color(1,1,1,1)
	else:
		modulate = Color(1,1,1,0)
	
func _process(_delta):
	visible = global_position.x >= Global.note_culling_bounds.x - width/2 and global_position.x < Global.note_culling_bounds.y + width/2
