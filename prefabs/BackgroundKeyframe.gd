extends Node2D

var data: Dictionary
var beat: float

var move_pos: bool
var mouse_pos: float
var mouse_pos_start: float
var mouse_pos_end: float
var selected_key: Node2D

func _ready():
	Events.update_notespeed.connect(update_position)

func setup(keyframe_data):
	move_pos = false
	data = keyframe_data
	beat = Global.get_beat_at_time(data['timestamp'])
	$InputHandler.tooltip_text = data['path']
	$Thumb.texture = Assets.get_asset(data['path'])
	if $Thumb.texture:
		$Thumb.texture_filter = TEXTURE_FILTER_LINEAR
		var frame_size = $Thumb.texture.get_size()
		var ratio = 104
		scale = Vector2(ratio,ratio)/frame_size
		$InputHandler.size = frame_size
		$InputHandler.position = -$InputHandler.size/2
		update_position()

func update_position():
	data['timestamp'] = Global.get_time_at_beat(beat)
	position.x = -((data['timestamp'] - Global.offset) * Global.note_speed)

func update_beat_and_position(time: float):
	beat = Global.get_beat_at_time(time)
	data['timestamp'] = time
	position.x = -((data['timestamp'] - Global.offset) * Global.note_speed)

func _on_input_handler_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					selected_key = self
					mouse_pos_start = self['data']['timestamp']
					if event.double_click:
						Popups.id = 1
						Events.emit_signal('add_background_to_timeline', data)
				MOUSE_BUTTON_MIDDLE:
					print(Save.keyframes['background'].find(data))
				MOUSE_BUTTON_RIGHT:
					Global.project_saved = false
					Timeline.delete_keyframe('background', self, Save.keyframes['background'].find(data))

func _on_mouse_exited():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): move_pos = true
