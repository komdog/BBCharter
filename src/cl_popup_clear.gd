extends Panel

func _ready():
	Events.popups_closed.connect(_on_popups_closed)

func _on_yes_button_up():
	if Popups.id == 0:
		Timeline.clear_notes_only()
	elif Popups.id == 1:
		Global.clear_children(Timeline.animations_track)
	elif Popups.id == 2:
		Global.clear_children(Timeline.oneshot_sound_track)
	elif Popups.id == 3:
		Global.clear_children(Timeline.shutter_track)
	elif Popups.id == 4:
		Timeline.clear_timeline()
	await get_tree().process_frame
	Popups.close()

func _on_no_button_up():
	Popups.close()

func _on_popups_closed():
	Popups.id = -1
