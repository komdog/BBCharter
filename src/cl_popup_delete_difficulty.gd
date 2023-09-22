extends Panel

func _on_yes_button_up():
	Events.emit_signal('difficulty_deleted', Global.difficulty_index)
	await get_tree().process_frame
	Popups.close()

func _on_no_button_up():
	Popups.close()
