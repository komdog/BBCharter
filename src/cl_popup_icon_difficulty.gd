extends Panel

func _ready():
	Events.popups_opened.connect(_on_popups_opened)

func _on_popups_opened(index):
	if index == Popups.ICONDIFFICULTY:
		var notes = Save.notes["charts"][Global.difficulty_index]
		var icon = ""
		if notes.has("icon"): icon = notes["icon"]
		
		$File.text = icon.trim_suffix(".png")
		$Icon.texture = Assets.get_asset(icon)
		if $Icon.texture == null: $Icon.texture = preload("res://assets/icon_difficulty.png")

func _on_file_text_changed(text):
	if !text.ends_with(".png"):
		text = text + ".png"
	$Icon.texture = Assets.get_asset(text)
	if $Icon.texture == null:
		$Icon.texture = preload("res://assets/icon_difficulty.png")

func _on_set_button_up():
	if $File.text == "":
		Save.notes["charts"][Global.difficulty_index].erase("icon")
	else:
		if !$File.text.ends_with(".png"):
			$File.text = $File.text + ".png"
		Save.notes["charts"][Global.difficulty_index]["icon"] = $File.text
	Events.emit_signal('notify', 'Difficulty Icon Set', $File.text, Save.project_dir + "/images/" + $File.text)
	Global.project_saved = false
	Popups.close()

func _on_cancel_button_up():
	Popups.close()
