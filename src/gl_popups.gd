extends Node

enum {NEWDIFFICULTY,DELETEDIFFICULTY,RENAMEDIFFICULTY,ICONDIFFICULTY,PLACEANIMATION,CLEAR,QUIT}

var popup: Control
var open: bool
var id: int = -1

func reveal(index):
	close()
	popup.show()
	popup.get_children()[index].show()
	open = true
	Events.emit_signal('popups_opened')
	
func close():
	popup.hide()
	for child in popup.get_children():
		child.hide()
		
	open = false
	Events.emit_signal('popups_closed')
	
	
