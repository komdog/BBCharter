extends Node2D

var hit: bool
var data: Dictionary

func _ready():
	Events.update_notespeed.connect(update_position)
	Events.update_selection.connect(update_selection)

func setup(note_data):
	data = note_data
	update_visual()
	update_position()

func update_position():
	position.x = -(data['timestamp'] * Global.note_speed)

func update_selection(a,b):
	if b >= a:
		if data['timestamp'] + Global.offset >= a and data['timestamp'] + Global.offset <= b:
			set_selected()
	elif a >= b:
		if data['timestamp'] + Global.offset >= b and data['timestamp'] + Global.offset <= a:
			set_selected()
	
func _process(_delta):
	visible = global_position.x >= Global.note_culling_bounds.x and global_position.x < Global.note_culling_bounds.y
	
	if global_position.x >= 960 and !hit:
		Events.emit_signal('hit_note', data)
		hit = true
	elif global_position.x < 960 and hit:
		hit = false
		
func update_visual():
	$Voice.visible = data.has('trigger_voice')
	$Selected.visible = Clipboard.selected_notes.has(self)
	$Visual.self_modulate = Global.note_colors[data['input_type']]
	

func _on_input_handler_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if Global.current_tool == Enums.TOOL.SELECT:
						set_selected()
					elif Global.current_tool == Enums.TOOL.MARQUEE:
						pass
					else:
						Global.project_saved = false
					if Global.current_tool == Enums.TOOL.VOICE:
						toggle_voice_trigger()
				MOUSE_BUTTON_RIGHT:
					Global.project_saved = false
					if Global.current_tool == Enums.TOOL.SELECT:
						Timeline.delete_note(self, Global.current_chart.find(data))

func set_selected():
	if Clipboard.selected_notes.has(self):
		Clipboard.selected_notes.erase(self)
	else:
		Clipboard.selected_notes.append(self)			
	update_visual()
	
	print(Clipboard.selected_notes)
	
func toggle_voice_trigger():
	if data.has('trigger_voice'):
		data.erase('trigger_voice')
	else:
		data['trigger_voice'] = true
	update_visual()
