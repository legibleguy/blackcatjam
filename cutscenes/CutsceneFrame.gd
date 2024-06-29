class_name CutsceneFrame extends Resource

@export var customBackground : Image
@export var cutsceneSheet : AnimatedTexture
@export var cutsceneCaption : String

@export var sheetFromPath : bool = false
@export var sheetPath : String = ""

func _init():
	if sheetFromPath and cutsceneSheet == null:#		
		pass
		#var path = "path/to/folder"
#		var dir = Directory.new()
#		dir.open(path)
#		dir.list_dir_begin()
#		while true:
#			var file_name = dir.get_next()
#			if file_name == "":
#				#break the while loop when get_next() returns ""
#				break
#			elif !file_name.begins_with("."):
#				#get_next() returns a string so this can be used to load the images into an array.
#				your_image_array.append(load(path + file_name))
#		dir.list_dir_end()
