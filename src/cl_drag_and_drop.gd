extends Node


func get_file_type(files):
	print('Getting dropped files')
	print(files)
	if Save.project_dir != "":
		var dir = DirAccess.open(Save.project_dir)

		for file in files:
			if file.get_extension() == "mp3":
				dir.copy(file, Save.project_dir + "/audio/" + file.get_file())
			elif file.get_extension() == "png":
				dir.copy(file, Save.project_dir + "/images/" + file.get_file())
		
		Events.emit_signal('project_loaded')
