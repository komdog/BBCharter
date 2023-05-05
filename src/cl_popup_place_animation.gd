extends Panel

var animation_name: String

func _ready():
	Events.popups_closed.connect(_on_popups_closed)
	Events.add_animation_to_timeline.connect(_on_add_animation_to_timeline)
	

func _on_create_button_up() -> void:
	Global.project_saved = false

	var new_animation_key =	{
		"timestamp": Global.get_timestamp_snapped(),
		"sheet_data": {"h": $SheetH.value, "v": $SheetV.value, "total": $Total.value},
		"scale_multiplier": 1.0,
		"position_offset": {"x": 0 ,"y": 0},
		"animations": {
			"normal": animation_name,
			"horny": animation_name
			}
		}

	Save.keyframes['loops'].append(new_animation_key)
	Save.keyframes['loops'].sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
	Timeline.note_controller.spawn_single_keyframe(new_animation_key, Prefabs.animation_keyframe, Timeline.animations_track)
	Popups.close()
	print(new_animation_key)


func _on_cancel_button_up():
	Popups.close()

func _on_popups_closed():
	pass
#	$DifficultyNameField.clear()
	
func _on_add_animation_to_timeline(asset_path):
	animation_name = asset_path
	Popups.reveal(Popups.PLACEANIMATION)
