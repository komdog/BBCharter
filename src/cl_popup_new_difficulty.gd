extends Panel


func _ready():
	Events.popups_opened.connect(_on_popups_opened)
	Events.popups_closed.connect(_on_popups_closed)

func _on_popups_opened():
	if Save.notes['charts'].size() > Global.difficulty_max:
		Popups.close()
		Events.emit_signal('notify', 'Error creating difficulty', 'You\'ve reached the max amount!', Save.project_dir + "/thumb.png")
	else:
		$DifficultyCount.text = str(Save.notes['charts'].size()) + ' / ' + str(Global.difficulty_max+1)

func _on_create_button_up() -> void:
	Global.project_saved = false
	
	var difficulty_name = $DifficultyNameField.text
	var difficulty_rating = Save.notes['charts'].size()
	
	if Save.notes.is_empty(): return print('Error creating difficulty')

	if !difficulty_name.is_valid_filename(): return print('Invalid Filename')
	Save.create_difficulty(difficulty_name, difficulty_rating)
	Save.load_chart(Save.notes['charts'].size()-1)
	Events.emit_signal('difficulty_created')
	Popups.close()

func _on_cancel_button_up():
	Popups.close()

func _on_popups_closed():
	$DifficultyNameField.clear()
	

