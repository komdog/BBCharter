extends PopupMenu

enum {RELOADPROJECT,NEWDIFFICULTY,DELETEDIFFICULTY,RENAMEDIFFICULTY}

func _ready():
	Events.project_loaded.connect(_on_project_loaded)
	
func _on_id_pressed(id: int):
	match id:
		RELOADPROJECT:
			Save.load_project(Save.project_dir)
		NEWDIFFICULTY:
			Popups.reveal(Popups.NEWDIFFICULTY)
		DELETEDIFFICULTY:
			Save.delete_difficulty()
		RENAMEDIFFICULTY:
			Popups.reveal(Popups.RENAMEDIFFICULTY)
			

func _on_project_loaded():
	for i in item_count:
		set_item_disabled(i,false)
