extends Node2D

var data: Dictionary
var selected: bool

func _ready():
	Events.update_notespeed.connect(update_position)

func setup(keyframe_data):
	data = keyframe_data
#	$Visual.modulate = Color(1,1,0.5,1)
	$Thumb.texture = Assets.get_asset(data['animations']['normal'])
	if $Thumb.texture:
		$Thumb.hframes = data['sheet_data']["h"] # Get hframes from preset
		$Thumb.vframes = data['sheet_data']["v"] # Get vframes from preset
		$Thumb.texture_filter = TEXTURE_FILTER_LINEAR
		var frame_size = $Thumb.texture.get_size() / Vector2($Thumb.hframes, $Thumb.vframes)
		var ratio = 104
		scale = Vector2(ratio * 1.777,ratio)/frame_size
		$InputHandler.size = frame_size
		$InputHandler.position = -$InputHandler.size/2
		update_position()

func update_position():
	position.x = -(data['timestamp'] * Global.note_speed)


func _on_input_handler_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_MIDDLE:
				print(Save.keyframes['loops'].find(data))
			MOUSE_BUTTON_RIGHT:
				Timeline.delete_keyframe('loops', self, Save.keyframes['loops'].find(data))
