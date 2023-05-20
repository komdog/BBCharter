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
		Events.emit_signal('miss_note', data)
		hit = false
		
func update_visual():
	$Voice.visible = data.has('trigger_voice')
	$Selected.visible = Clipboard.selected_notes.has(self)
	$Visual.self_modulate = Global.note_colors[data['input_type']]
	$Glow.self_modulate = Global.note_colors[data['input_type']]
	$Label.add_theme_constant_override('outline_size', 8)
	if data['note_modifier'] == 1:
		$Handsfree.visible = true
		$Handsfree/Handsfreeinner.self_modulate = Global.note_colors[data['input_type']]
		$Handsfree/Handsfreeinner.visible = !($Voice.visible)
		$Voice.self_modulate = Global.note_colors[data['input_type']]
	else:
		$Handsfree.visible = false
		$Voice.self_modulate = Color.ANTIQUE_WHITE
	if data['note_modifier'] == 2:
		$Visual.modulate = Color(1,1,1,0.7)
		$Glow.modulate = Color(1,1,1,0.7)
	else:
		$Visual.modulate = Color.WHITE
		$Glow.modulate = Color.WHITE
	if data.has('horny') and data['horny'].has('required') and data['horny']['required'] >= 0:
		$Glow.visible = true
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
		$Glow.visible = false
		$Label.text = ''
		$Voice.scale = Vector2(0.444,0.444)
		$Handsfree/Handsfreeinner.scale = Vector2(0.2,0.2)

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
					if Global.current_tool == Enums.TOOL.HORNY:
						horny_add()
					if Global.current_tool == Enums.TOOL.MODIFY:
						modify_cycle(1)
				MOUSE_BUTTON_RIGHT:
					Global.project_saved = false
					if Global.current_tool == Enums.TOOL.SELECT:
						Timeline.delete_note(self, Global.current_chart.find(data))
					if Global.current_tool == Enums.TOOL.HORNY:
						horny_remove()
					if Global.current_tool == Enums.TOOL.MODIFY:
						modify_cycle(-1)

func set_selected():
	if Clipboard.selected_notes.has(self):
		Clipboard.selected_notes.erase(self)
	else:
		Clipboard.selected_notes.append(self)			
	update_visual()
	
	print(Clipboard.selected_notes)
	
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
	if data['note_modifier'] == 1: data['note_modifier'] += 1 # Remove once Auto Notes are implemented
	update_visual()
	Events.emit_signal('tool_used_after', data)
