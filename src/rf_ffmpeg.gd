extends Node


# Called when the node enters the scene tree for the first time.
func make_sprite_sheet(file, dest):
	var output = []
	var dir = ProjectSettings.globalize_path("res://")
		
	# Define Directories for command
	var folder = file.get_file().get_basename()
	var input = file
	var sheets_out = "./output/sheets/%s.png" % file.get_file().get_basename()
	
	# Make Image Sequence
	var sequence_destination =  dest + "/temp_" + folder
	DirAccess.make_dir_absolute(sequence_destination)
	var sequence_files = sequence_destination + "/output%03d.png"
	
	print(sequence_destination)
	print(sequence_files)
	
	return
	

	# Make an image sequence for calculating sheet size
#	OS.execute("CMD.exe", ["/C", "cd %s | ffmpeg -i %s -vf scale=-1:720,mpdecimate,setpts=N/FRAME_RATE/TB %s" % [dir, input, seq_out]], output)
	
	var file_count = Assets.get_file_list_of_type(dir + "output/" + folder, "png").size()
	var width = 4.0
	var hieght = ceili(float(file_count)/width)
	
	var factors = "%sx%s" % [width,hieght]
	
#	OS.execute("CMD.exe", ["/C", "cd %s | ffmpeg -i %s -filter_complex tile=%s %s" % [dir, seq_out, factors, sheets_out]], output)
	
	remove_temp_folder("output/" + folder)
#		OS.shell_open(dir + "output/sheets/%s.png" % file.get_file().get_basename())


func remove_temp_folder(path: String):
	var dir = ProjectSettings.globalize_path("res://") + path
	print("Removing %s" % dir)
	var files = DirAccess.get_files_at(dir)
	
	for file in files:
		DirAccess.remove_absolute(dir + "/" + file)
		
	DirAccess.remove_absolute(dir)
