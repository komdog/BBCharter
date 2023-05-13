extends PopupMenu

enum {CHART,ANIMATION,ONESHOT,SHUTTER,TIMELINE}

func _ready():
	Events.project_loaded.connect(_on_project_loaded)

func _on_id_pressed(id: int):
	match id:
		CHART:
			if Global.current_chart.size() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Notes To Clear')
		ANIMATION:
			if Timeline.animations_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Animations To Clear')
		ONESHOT:
			if Timeline.oneshot_sound_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Oneshot Sounds To Clear')
		SHUTTER:
			if Timeline.shutter_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Shutter Effects To Clear')
		TIMELINE:
			if Global.current_chart.size() > 0 or Timeline.animations_track.get_child_count() > 0 or Timeline.oneshot_sound_track.get_child_count() > 0 or Timeline.shutter_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('Nothing To Clear')

func _on_project_loaded():
	for i in item_count:
		set_item_disabled(i,false)
