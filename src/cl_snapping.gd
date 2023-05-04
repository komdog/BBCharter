extends OptionButton


func _ready():
	Events.update_snapping.connect(_on_update_snapping)
	
	if Global.snapping_ratios.has(Global.snapping_factor):
		selected = Global.snapping_ratios.find(Global.snapping_factor)

func _on_item_selected(index):
	Global.snapping_factor = Global.snapping_ratios[index]
	Events.emit_signal('update_snapping', index)
	selected = index

func _on_update_snapping(index):
	print('Snapping set to 1/%s' % Global.snapping_ratios[index])

func _input(event):
	
	if Popups.open: return
	
	if event.is_action_pressed("snap_1"):
		_on_item_selected(0)
	elif event.is_action_pressed("snap_2"):
		_on_item_selected(1)
	elif event.is_action_pressed("snap_3"):
		_on_item_selected(2)
	elif event.is_action_pressed("snap_4"):
		_on_item_selected(3)


func _on_snap_toggle_toggled(state: bool):
	Global.snapping_allowed = state
	$SnapToggle.text = "SNAPPING : ON" if state else "SNAPPING : OFF"
