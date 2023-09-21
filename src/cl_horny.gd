extends AudioStreamPlayer

func _ready():
	Events.horny_mode.connect(_on_horny_mode)

func _on_horny_mode():
	if Save.asset.has('horny_mode_sound'):
		stream = Assets.get_asset(Save.asset['horny_mode_sound'])
		play()
