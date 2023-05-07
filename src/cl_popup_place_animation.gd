extends Panel

var animation_name: String

func _ready():
	Events.popups_closed.connect(_on_popups_closed)
	Events.add_animation_to_timeline.connect(_on_add_animation_to_timeline)
	

func _on_create_button_up() -> void:
	var new_animation_key =	{
		"timestamp": Global.get_timestamp_snapped(),
		"sheet_data": {"h": $SheetH.value, "v": $SheetV.value, "total": $Total.value},
		"scale_multiplier": $Scale.value,
		"position_offset": {"x": $OffsetX.value ,"y": $OffsetY.value},
		"animations": {
			"normal": animation_name,
			"horny": $Horny.text if $Horny.text != "" else animation_name
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
	$Horny.clear()
	
func _on_add_animation_to_timeline(asset_path):
	animation_name = asset_path
	Popups.reveal(Popups.PLACEANIMATION)
