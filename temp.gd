extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().files_dropped.connect(on_files_dropped)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func on_files_dropped(files):
	var output = []


	var dir = ProjectSettings.globalize_path("res://")
	
	for file in files:
		
		# Define Directories for command
		var folder = file.get_file().get_basename()
		var input = file
		var seq_out = "./output/" + folder + "/output%03d.png"
		var sheets_out = "./output/sheets/%s.png" % file.get_file().get_basename()
		
		# Make Folder for Images
		DirAccess.make_dir_absolute("res://output/%s" % folder)
		DirAccess.make_dir_absolute("res://output/sheets")
		
		# Add .gdignore
		var newfile2 = FileAccess.open("res://output/sheets/.gdignore", FileAccess.WRITE)
		newfile2.store_string("...")

		# Make an image sequence for calculating sheet size
		OS.execute("CMD.exe", ["/C", "cd %s | ffmpeg -i %s -vf scale=-1:720,mpdecimate,setpts=N/FRAME_RATE/TB %s" % [dir, input, seq_out]], output)
		
		var file_count = Assets.get_file_list_of_type(dir + "output/" + folder, "png").size()
		var width = 4.0
		var hieght = ceili(float(file_count)/width)
		
		var factors = "%sx%s" % [width,hieght]
		
		OS.execute("CMD.exe", ["/C", "cd %s | ffmpeg -i %s -filter_complex tile=%s %s" % [dir, seq_out, factors, sheets_out]], output)
		
		remove_temp_folder("output/" + folder)
#		OS.shell_open(dir + "output/sheets/%s.png" % file.get_file().get_basename())

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


func remove_temp_folder(path: String):
	var dir = ProjectSettings.globalize_path("res://") + path
	print("Removing %s" % dir)
	var files = DirAccess.get_files_at(dir)
	
	for file in files:
		DirAccess.remove_absolute(dir + "/" + file)
		
	DirAccess.remove_absolute(dir)

