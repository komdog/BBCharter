extends Node

@onready var ffmpeg = preload("res://src/sh_ffmpeg.gd").new()

var file_types = {
	"mp3": "/audio/",
	"png": "/images/",
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
		
		if !file_types.has(extention): return print('%s files are not supported' % extention)
		if extention == "mp4" or extention == "webm": return ffmpeg.make_sprite_sheet(file, dest)
		dir.copy(file, dest + file.get_file())
		
	Events.emit_signal('project_loaded')
