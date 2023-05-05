extends Panel

func _on_yes_button_up():
	Timeline.clear_notes_only()
	await get_tree().process_frame
	Popups.close()

func _on_no_button_up():
	Popups.close()
