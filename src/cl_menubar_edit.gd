extends PopupMenu

enum {UNDO,REDO}

func _ready():
	Events.project_loaded.connect(_on_project_loaded)

func _on_id_pressed(id: int):
	match id:
		UNDO:
			pass
		REDO:
			pass

func _on_project_loaded():
	pass
