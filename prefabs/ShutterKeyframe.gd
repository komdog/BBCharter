extends Node2D

var data

func _ready():
	Events.update_notespeed.connect(update_position)

func setup(keyframe_data):
	data = keyframe_data
	update_position()

func update_position():
	position.x = -(data['timestamp'] * Global.note_speed)

func _on_input_handler_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_MIDDLE:
				print(Save.keyframes['shutter'].find(data))
			MOUSE_BUTTON_RIGHT:
				Global.project_saved = false
				Timeline.delete_keyframe('shutter', self, Save.keyframes['shutter'].find(data))

