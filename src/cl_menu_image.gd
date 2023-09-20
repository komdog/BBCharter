extends PopupMenu

enum {ADDANIMATION,ADDBACKGROUND,SETICON}

var asset_path

func _ready():
	Events.open_image_menu.connect(_on_open_image_menu)

func _on_open_image_menu(path,pos):
	asset_path = path
	show()
	position = pos

func _on_id_pressed(id: int):
	var time: float
	if Global.snapping_allowed: time = Global.get_timestamp_snapped()
	else: time = Global.song_pos
	
	match id:
		ADDANIMATION:
			Popups.id = 0
			Events.emit_signal('add_animation_to_timeline', asset_path)
		ADDBACKGROUND:
			Popups.id = 0
			Events.emit_signal('add_background_to_timeline', asset_path)
		SETICON:
			Save.notes["charts"][Global.difficulty_index]["icon"] = asset_path
			Events.emit_signal('notify', 'Difficulty Icon Set', asset_path, Save.project_dir + "/images/" + asset_path)
			Global.project_saved = false
