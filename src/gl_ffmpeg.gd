extends Node


# Called when the node enters the scene tree for the first time.
func make_sprite_sheet(file, dest):
	var output = []
		
	# Define Directories for command
	var folder = file.get_file().get_basename()
	var _output_filename = "%s.png" % file.get_file().get_basename()
	
	# Make Image Sequence
	var sequence_destination =  dest + "temp_" + folder
	DirAccess.make_dir_absolute(sequence_destination)
	var sequence_files = sequence_destination + "/output%03d.png"

	# Make an image sequence for calculating sheet size | Remove duplicate frames
	OS.execute("ffmpeg", ["-i", file, "-vf", "scale=-1:720,mpdecimate,setpts=N/FRAME_RATE/TB",sequence_files], output)
	
	var file_count = Assets.get_file_list_of_type(sequence_destination, "png").size()
	var factors = "%sx%s" % calcuate_sprite_sheet_size(file_count)
	
	print("Generating %s Spritesheet" % factors)

	OS.execute("ffmpeg", ["-i", sequence_files, "-filter_complex", "tile=" + factors, dest + folder + ".png"], output)

	remove_temp_folder(sequence_destination)
	
	Assets.load_single_image(folder + ".png")


func calcuate_sprite_sheet_size(total_frames: int) -> Array:
	var h = floor(sqrt(total_frames))
	var w	
	
	if h * h == total_frames:
		w = h
	else:
		w = ceil(total_frames/h)

	return [w,h]


func remove_temp_folder(path: String):
	print("Removing temp folder")
	var files = DirAccess.get_files_at(path)
	for file in files:
		DirAccess.remove_absolute(path + "/" + file)
	DirAccess.remove_absolute(path)
