extends PopupMenu

enum {CHART,SHUTTER,ANIMATION,BACKGROUND,MODIFIER,SOUNDLOOP,ONESHOT,TIMELINE}

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
		SHUTTER:
			if Timeline.shutter_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Shutter Effects To Clear')
		ANIMATION:
			if Timeline.animations_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Animations To Clear')
		BACKGROUND:
			if Timeline.backgrounds_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Backgrounds To Clear')
		MODIFIER:
			if Timeline.modifier_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Modifiers To Clear')
		SOUNDLOOP:
			if Timeline.sfx_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Sound Loops To Clear')
		ONESHOT:
			if Timeline.oneshot_sound_track.get_child_count() > 0:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id
			else:
				print('No Oneshot Sounds To Clear')
		TIMELINE:
			if is_timeline_empty():
				print('Nothing To Clear')
			else:
				Popups.reveal(Popups.CLEAR)
				Popups.id = id

func is_timeline_empty():
	return !(Global.current_chart.size() > 0
	or Timeline.shutter_track.get_child_count() > 0
	or Timeline.animations_track.get_child_count() > 0
	or Timeline.backgrounds_track.get_child_count() > 0
	or Timeline.modifier_track.get_child_count() > 0
	or Timeline.sfx_track.get_child_count() > 0
	or Timeline.oneshot_sound_track.get_child_count() > 0)

func _on_project_loaded():
	for i in item_count:
		set_item_disabled(i,false)
