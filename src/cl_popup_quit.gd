extends Panel



func _on_save_button_up():
	Save.save_project()
	await get_tree().process_frame
	get_tree().quit()

func _on_discard_button_up():
	get_tree().quit()

func _on_cancel_button_up():
	Popups.close()





