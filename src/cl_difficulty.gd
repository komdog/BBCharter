extends OptionButton

func _ready():
	Events.project_loaded.connect(_on_project_loaded)
	Events.difficulty_created.connect(_on_difficulty_created)
	Events.difficulty_renamed.connect(_on_difficulty_renamed)
	Events.difficulty_deleted.connect(_on_difficulty_deleted)

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

func _on_difficulty_created():
	var difficulty = Save.notes['charts'][Save.notes['charts'].size()-1]
	add_item(difficulty['name'], item_count)
	selected = item_count-1
	Events.emit_signal('notify', 'Created Difficulty', difficulty['name'], Save.project_dir + "/thumb.png")

func _on_difficulty_renamed(stuff):
	var difficulty = Save.notes['charts'][stuff[0]]
	set_item_text(stuff[0], difficulty['name'])
	Events.emit_signal('notify', 'Renamed Difficulty', stuff[1] + ' → ' + difficulty['name'], Save.project_dir + "/thumb.png")

func _on_difficulty_deleted(index):
	var old_difficulty = get_item_text(index)
	remove_item(index)

	selected = index
	if index >= item_count:
		selected = item_count-1
	
	Save.load_chart(index)
	Events.emit_signal('notify', 'Removed Difficulty', old_difficulty, Save.project_dir + "/thumb.png")
