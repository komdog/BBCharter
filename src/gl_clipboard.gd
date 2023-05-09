extends Node

var selected_notes: Array

func _input(event):
	if event.is_action_pressed("delete") and !selected_notes.is_empty():
		Global.project_saved = false
		
		for note in selected_notes:
			Timeline.delete_note(note, Global.current_chart.find(note['data']))
			
		selected_notes.clear()
