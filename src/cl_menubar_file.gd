extends PopupMenu

enum {NEWPROJECT,OPENPROJECT,SAVEPROJECT}

func _ready():
	Events.project_loaded.connect(_on_project_loaded)

func _on_id_pressed(id: int):
	match id:
		NEWPROJECT:
			Global.file_dialog.new_project_dialog()
		OPENPROJECT:
			Global.file_dialog.open_project_dialog()
		SAVEPROJECT:
			Save.save_project()

func _on_project_loaded():
	for i in item_count:
		set_item_disabled(i, false)
