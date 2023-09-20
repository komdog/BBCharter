extends PopupMenu

enum {UNDO,REDO,REPLACE}

func _ready():
	hide_on_checkable_item_selection = false

func _on_id_pressed(id: int):
	match id:
		UNDO:
			pass
		REDO:
			pass
		REPLACE:
			set_item_checked(id + 1, !is_item_checked(id + 1))
			Global.replacing_allowed = is_item_checked(id + 1)
			print("Replacing " + ("Enabled" if Global.replacing_allowed else "Disabled"))
