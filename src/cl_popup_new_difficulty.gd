extends Panel


func _ready():
	Events.popups_closed.connect(_on_popups_closed)

func _on_create_button_up() -> void:
	
	var difficulty_name = $DifficultyNameField.text
	var difficulty_rating = int($DifficultyRatingField.value)
	
	if Save.notes.is_empty(): return print('Error creating difficulty')

	if !difficulty_name.is_valid_filename(): return print('Invalid Filename')
	Save.create_difficulty(difficulty_name, difficulty_rating)
	Save.save_project()
	Save.load_chart(Save.notes['charts'].size()-1)
	Events.emit_signal('difficulty_created')
	Popups.close()

func _on_cancel_button_up():
	Popups.close()

func _on_popups_closed():
	$DifficultyNameField.clear()
	

