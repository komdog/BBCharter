extends Node

var file_types = {
	"mp3": "/audio/",
	"png": "/images/",
	"gif": "/images/",
	"mp4": "/images/",
	"webm": "/images/",
}


func get_file_type(files) -> void:
	print('Getting %s dropped files' % files.size())
	
	# Check if project is loaded
	if Save.project_dir.is_empty(): return print('No project directory found')
	var dir = DirAccess.open(Save.project_dir)

	# Copy each file to folder

	for file in files:

		var extention = file.get_extension()
		var dest = Save.project_dir + file_types[extention]

		# If files are vaild then copy
		if validate_files(file, extention, dest) == OK:
			dir.copy(file, dest + file.get_file())
			Assets.load_single_image(file.get_file())

	Events.emit_signal('project_loaded')


func validate_files(file: String, extention: String, dest: String):
	# Check if Support
	if !file_types.has(extention): 
		print('%s files are not supported' % extention)
		return FAILED
	
	# Check if conversion needed
	if extention == "mp4" or extention == "webm" or extention == "gif": 
		Media.make_sprite_sheet(file, dest)
		return FAILED
		
	return OK
	
	
	
	
