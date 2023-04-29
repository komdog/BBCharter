extends OptionButton

func _ready():
	Events.project_loaded.connect(_on_project_loaded)
	Events.difficulty_created.connect(_on_project_loaded)

func _on_item_selected(id: int):
	print("Changing Difficulty...")
	Save.load_chart(id)
	
	var notify_subheader = "%s (%s Notes)" % [Save.notes['charts'][id]['name'], Global.current_chart.size()]
	Events.emit_signal('notify', 'Changed Difficulty', notify_subheader, Save.project_dir + "/thumb.png")

func _on_project_loaded():
	clear()
	for i in Save.notes['charts'].size():
		var difficulty = Save.notes['charts'][i]
		add_item(difficulty['name'], i)

