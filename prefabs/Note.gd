extends Node2D

var hit: bool
var data: Dictionary
var beat: float

var move_pos: bool
var mouse_pos: float
var mouse_pos_start: float
var mouse_pos_end: float
var clear_clipboard: bool
var selected_note: Node2D

func _ready():
	Events.update_notespeed.connect(update_position)
	Events.update_bpm.connect(update_position)
	Events.update_position.connect(update_position)

func setup(note_data):
	data = note_data
	move_pos = false
	clear_clipboard = false
	beat = Global.get_beat_at_time(data['timestamp'])
	update_visual()
	update_position()

func update_position():
	#print("pos update")
	data['timestamp'] = Global.get_time_at_beat(beat)
	position.x = -((data['timestamp'] - Global.offset) * Global.note_speed)

func update_beat_and_position(time: float):
	#print("pos and beat update")
	beat = Global.get_beat_at_time(time)
	data['timestamp'] = time
	position.x = -((data['timestamp'] - Global.offset) * Global.note_speed)

func _input(_event):
	pass
	#if event is InputEventKey: clear_clipboard = !event.is_command_or_control_pressed()
	#if event is InputEventMouseButton:
		#print(event)
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#if Global.current_tool == Enums.TOOL.SELECT:
			#if (get_viewport().get_mouse_position().x < $InputHandler.global_position.x
			#or get_viewport().get_mouse_position().x > $InputHandler.global_position.x + $InputHandler.size.x
			#and clear_clipboard):
				#Clipboard.selected_notes.clear()
				#update_visual()

func _process(_delta):
	visible = global_position.x >= Global.note_culling_bounds.x and global_position.x < Global.note_culling_bounds.y
	$Selected.visible = Clipboard.selected_notes.has(self)
	if global_position.x >= 960 and !hit:
		print("Hit?")
		Events.emit_signal('hit_note', data)
		hit = true
	elif global_position.x < 960 and hit:
		print("Hit?2")
		Events.emit_signal('miss_note', data)
		hit = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Global.snapping_allowed: mouse_pos = Global.get_mouse_timestamp_snapped()
		else: mouse_pos = Global.get_mouse_timestamp()
		if mouse_pos < 0: mouse_pos = 0
		
		#if selected_note != null:
			#if clear_clipboard: Clipboard.selected_notes.clear()
			#else: Clipboard.selected_notes.append(selected_note)
			#update_visual()
		if Clipboard.selected_notes.is_empty():return
		if Global.current_tool != Enums.TOOL.SELECT: return
		if move_pos:
			if selected_note != null:
				selected_note.update_beat_and_position(mouse_pos)
				Global.current_chart.sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
			else:
				move_pos = false

func update_visual():
	print("update visual!")
	$Voice.visible = data.has('trigger_voice')
	$Visual.self_modulate = Global.note_colors[data['input_type']]
	$Glow.self_modulate = Global.note_colors[data['input_type']]
	$Label.add_theme_constant_override('outline_size', 8)
	if data['note_modifier'] == 1:
		$Handsfree.show()
		$Handsfree/Handsfreeinner.self_modulate = Global.note_colors[data['input_type']]
		$Handsfree/Handsfreeinner.visible = !($Voice.visible)
		$Voice.self_modulate = Global.note_colors[data['input_type']]
	else:
		$Handsfree.hide()
		$Voice.self_modulate = Color.ANTIQUE_WHITE
	if data['note_modifier'] == 2:
		$Visual.modulate = Color(1,1,1,0.7)
		$Glow.modulate = Color(1,1,1,0.7)
	else:
		$Visual.modulate = Color.WHITE
		$Glow.modulate = Color.WHITE
	if data.has('horny') and data['horny'].has('required') and data['horny']['required'] >= 0:
		$Glow.show()
		$Label.text = str(data['horny']['required'])
		$Voice.scale = Vector2(0.666,0.666)
		$Handsfree/Handsfreeinner.scale = Vector2(0.5,0.5)
		if data.has('trigger_voice'):
			if data['note_modifier'] != 1:
				$Label.add_theme_color_override('font_color', Color.WHITE)
				$Label.add_theme_color_override('font_outline_color', $Visual.self_modulate)
			else:
				$Label.add_theme_color_override('font_color', $Visual.self_modulate)
				$Label.add_theme_color_override('font_outline_color', Color.WHITE)
		else:
			$Label.remove_theme_color_override('font_color')
			$Label.add_theme_color_override('font_outline_color', $Visual.self_modulate)
	else:
		$Glow.hide()
		$Label.text = ''
		$Voice.scale = Vector2(0.444,0.444)
		$Handsfree/Handsfreeinner.scale = Vector2(0.2,0.2)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if Global.current_tool == Enums.TOOL.SELECT:
						if !Clipboard.selected_notes.has(self):
							selected_note = self
							mouse_pos_start = self['data']['timestamp']
							if Clipboard.selected_notes.size() >= 1:
								Clipboard.clear_clipboard()
							if !Clipboard.selected_notes.has(selected_note):
								Clipboard.selected_notes.append(selected_note)
							update_visual()
						#elif Clipboard.selected_notes.has(self):
							#pass
						#else:
							#Clipboard.clear_clipboard()
							#update_visual()
					else:
						Global.project_saved = false
					if Global.current_tool == Enums.TOOL.VOICE:
						toggle_voice_trigger()
					if Global.current_tool == Enums.TOOL.HORNY:
						horny_add()
					if Global.current_tool == Enums.TOOL.MODIFY:
						modify_cycle(1)
				MOUSE_BUTTON_RIGHT:
					Global.project_saved = false
					if Global.current_tool == Enums.TOOL.SELECT or Global.current_tool == Enums.TOOL.MARQUEE:
						if Clipboard.selected_notes.size() > 1:
							for x in Clipboard.selected_notes:
								Timeline.delete_note(x, Global.current_chart.find(x.data))
						else:
							Timeline.delete_note(self, Global.current_chart.find(data))
					if Global.current_tool == Enums.TOOL.HORNY:
						horny_remove()
					if Global.current_tool == Enums.TOOL.MODIFY:
						modify_cycle(-1)
		else:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					if Global.current_tool == Enums.TOOL.SELECT:
						mouse_pos_end = mouse_pos
						for note in Timeline.note_container.get_children(): if note != selected_note: if snappedf(note['data']['timestamp'], 0.001) == snappedf(selected_note['data']['timestamp'], 0.001):
							if Global.replacing_allowed:
								Timeline.delete_note(note, Global.current_chart.find(note['data']))
							else:
								print('[Note] Note already exists at %s' % [snappedf(mouse_pos_end, 0.001)])
								selected_note.update_beat_and_position(mouse_pos_start)
								selected_note.move_pos = false
								break
						Global.current_chart.sort_custom(func(a, b): return a['timestamp'] < b['timestamp'])
						update_position()
						if mouse_pos_start != selected_note['data']['timestamp']: 
							Global.project_saved = false
						#selected_note = null
						mouse_pos_start = 0
						mouse_pos_end = 0 
						move_pos = false
						print("move pos false")

func horny_add():
	Events.emit_signal('tool_used_before', data)
	if !data.has('horny') or !data['horny'].has('required'):
		data['horny'] = {'required': 0}
	else:
		data['horny']['required'] += 1
	update_visual()
	Events.emit_signal('tool_used_after', data)

func horny_remove():
	Events.emit_signal('tool_used_before', data)
	if data.has('horny') and data['horny'].has('required'):
		if data['horny']['required'] == 0:
			data.erase('horny')
		else:
			data['horny']['required'] -= 1
	update_visual()
	Events.emit_signal('tool_used_after', data)

func toggle_voice_trigger():
	Events.emit_signal('tool_used_before', data)
	if data.has('trigger_voice'):
		data.erase('trigger_voice')
	else:
		data['trigger_voice'] = true
	update_visual()
	Events.emit_signal('tool_used_after', data)

func modify_cycle(i):
	Events.emit_signal('tool_used_before', data)
	data['note_modifier'] = wrapi(data['note_modifier'] + i, 0, 3)
	update_visual()
	Events.emit_signal('tool_used_after', data)

func _on_mouse_exited():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Global.current_tool == Enums.TOOL.SELECT: move_pos = true
