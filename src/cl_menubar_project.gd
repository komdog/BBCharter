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
			if Save.notes['charts'].size() > 1:
				Save.delete_difficulty()
			else:
				Events.emit_signal('notify', 'Error deleting difficulty', 'You can\'t delete the only one left!', "")
		RENAMEDIFFICULTY:
			Popups.reveal(Popups.RENAMEDIFFICULTY)
			

func _on_project_loaded():
	for i in item_count:
		set_item_disabled(i,false)
