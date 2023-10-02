extends Node

var selected_notes: Array

func _input(event):
	if Popups.open or Global.lock_timeline: return
	if event.is_action_pressed("delete") and !selected_notes.is_empty():
		Global.project_saved = false
		for note in selected_notes: if Global.current_chart.find(note['data']) > -1:
			Timeline.delete_note(note, Global.current_chart.find(note['data']))
		selected_notes.clear()

func clear_clipboard():
	print("Clear!")
	var clear_queue : Array = []
	for x in selected_notes.size():
		if selected_notes[x] == null: 
			clear_queue.append(x)
			continue
		selected_notes[x].selected_note = null
		selected_notes[x].move_pos = false
	for i in clear_queue.size():
		selected_notes.remove_at(clear_queue[i])
	selected_notes.clear()
