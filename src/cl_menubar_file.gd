extends PopupMenu


enum {NEWPROJECT,OPENPROJECT,SAVEPROJECT}

func _on_id_pressed(id: int):
	match id:
		NEWPROJECT:
			print("Can't do this yet...")
		OPENPROJECT:
			Global.filedialog.open_project_dialog()
		SAVEPROJECT:
			Save.save_project()
