extends PopupMenu

enum {TEMP1,TEMP2,CLEARCHART}

func _on_id_pressed(id: int):
	match id:
		CLEARCHART:
			#TODO: add an "ARE YOU SURE?" Prompt
			Timeline.clear_notes_only()

