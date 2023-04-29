extends Panel


func _ready():
	Popups.popup = self
	Popups.close()



func _on_gui_input(event):
	if event is InputEventMouseButton:
		Popups.close()
