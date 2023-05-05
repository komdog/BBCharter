extends PopupMenu

enum {TEMP1,TEMP2,CLEARCHART}

func _ready():
	Events.project_loaded.connect(_on_project_loaded)

func _on_id_pressed(id: int):
	match id:
		CLEARCHART:
			if Global.current_chart.size() > 0:
				Popups.reveal(Popups.CLEARCHART)
			else:
				print('No Notes To Clean')

func _on_project_loaded():
	set_item_disabled(CLEARCHART,false)
