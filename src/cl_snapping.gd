extends OptionButton


func _ready():
	Events.update_snapping.connect(_on_update_snapping)
	
	if Global.snapping_ratios.has(Global.snapping_factor):
		selected = Global.snapping_ratios.find(Global.snapping_factor)

func _on_item_selected(index):
	Global.snapping_factor = Global.snapping_ratios[index]
	Events.emit_signal('update_snapping', index)

func _on_update_snapping(index):
	print('Snapping set to 1/%s' % Global.snapping_ratios[index])


func _on_snap_toggle_toggled(state: bool):
	Global.snapping_allowed = state
	$SnapToggle.text = "SNAPPING : ON" if state else "SNAPPING : OFF"
