extends Node

enum {NEWDIFFICULTY,PLACEANIMATION,QUIT}

var popup: Control
var open: bool

func reveal(index):
	close()
	popup.show()
	popup.get_children()[index].show()
	open = true
	
func close():
	popup.hide()
	for child in popup.get_children():
		child.hide()
		
	open = false
	Events.emit_signal('popups_closed')
	
	
