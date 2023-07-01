extends Panel

func _on_yes_button_up():
	if Popups.id == 0:
		Timeline.clear_notes_only()
	elif Popups.id == 1:
		Timeline.delete_keyframes('shutter', Timeline.shutter_track)
	elif Popups.id == 2:
		Timeline.delete_keyframes('loops', Timeline.animations_track)
	elif Popups.id == 3:
		Timeline.delete_keyframes('background', Timeline.backgrounds_track)
	elif Popups.id == 4:
		for child in Timeline.modifier_track.get_children():
			if child.data['timestamp'] != 0: Timeline.delete_keyframe('modifiers', child, 0)
		Global.reload_bpm()
	elif Popups.id == 5:
		Timeline.delete_keyframes('sound_loop', Timeline.sfx_track)
	elif Popups.id == 6:
		Timeline.delete_keyframes('sound_oneshot', Timeline.oneshot_sound_track)
	elif Popups.id == 7:
		Timeline.clear_timeline()
	await get_tree().process_frame
	Popups.close()
	Popups.id = -1

func _on_no_button_up():
	Popups.close()
	Popups.id = -1
