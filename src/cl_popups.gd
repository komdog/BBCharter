extends Panel

func _ready():
	Popups.popup = self
	Popups.close()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		Popups.id = -1
		Popups.close()
