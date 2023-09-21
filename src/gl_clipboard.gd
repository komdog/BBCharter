extends Node

var selected_notes: Array

func _input(event):
	if Popups.open or Global.lock_timeline: return
	if event.is_action_pressed("delete") and !selected_notes.is_empty():
		Global.project_saved = false
		for note in selected_notes: if Global.current_chart.find(note['data']) > -1:
			Timeline.delete_note(note, Global.current_chart.find(note['data']))
		selected_notes.clear()
