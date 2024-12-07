class_name FileUtil

## Implements various complex logic pieces for dealing with filesystems
## Specifically, with loading resources/assets

## ---

## Function for recursively traversing a directory
## and producing a list of all the file PATHS.
static func get_all_file_paths_in_dir(path: String, file_extension := "", file_paths_so_far: Array[String] = []) -> Array[String]:
	var dir = DirAccess.open(path)
	
	## Directory FAILED to open, error and return early
	if dir == null:
		printerr("Error opening directory at " + path + ".")
		return file_paths_so_far
	
	## Begin directory traversal...
	dir.list_dir_begin()
	var current_name = dir.get_next()
	while current_name != "":
		var current_path = path.path_join(current_name)
		if dir.current_is_dir():
			## Recur down directory...
			get_all_file_paths_in_dir(current_path, file_extension, file_paths_so_far)
		elif file_extension and current_name.get_extension() == file_extension: 
			## Add file name that fits (if not null) extension criteria
			file_paths_so_far.append(current_path)
		
		## Next!
		current_name = dir.get_next()
	
	return file_paths_so_far

## JSON PARSING

## Parse a JSON file into a usable Dictionary.
static func parse_json_file_at_path_to_dict(path: String) -> Dictionary:
	## FILE ACCESS
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	
	## ERROR CHECKING
	if not error == OK:
		printerr("Issue with loading JSON file from " + path + ".")
		return {}
	
	return (json.data as Dictionary)
