class_name Logger

## LOGGER
## A basic static interface for general logging
## Logged outputs go to console(s)



#region CONFIG

static var print_to_godot_console = DebugConsole.CONFIG.print_to_godot_console # Console print flag
static var max_entries = DebugConsole.CONFIG.max_entries_before_cutoff # Maximum allowable entries before removal of old ones

static var log_file_name: String = DebugConsole.CONFIG.log_file_name_prefix
static var log_file_extension: String = "txt"

static var strip_bbcode: bool = DebugConsole.CONFIG.strip_bbcode

#endregion

#region LOGGING

signal entry_logged(str: String)
static var entries: Array[String]

## Log an entry to the entries list.
static func log(str: String) -> void:
	entries.append("%s\n" % str)
	
	if len(entries) > max_entries:
		entries.remove_at(0)
	
	# print(get_stack()) ## IMPLEMENT STACK TRACE
	
	DebugConsole.console_ui.print_string.call_deferred(str + "\n") # TEMP SOLUTION
	
	## And to also show it in the Godot console...
	if print_to_godot_console:
		print(str)
static func log_warning(str: String) -> void:
	entries.append("WARNING: %s\n" % str)
	
	if len(entries) > max_entries:
		entries.remove_at(0)
	
	DebugConsole.console_ui.print_string.call_deferred("[color=yellow]WARNING: " + str + "[/color]\n") # TEMP SOLUTION
	
	if print_to_godot_console:
		push_warning(str)
static func log_error(str: String) -> void:
	entries.append("ERROR: %s\n" % str)
	
	if len(entries) > max_entries:
		entries.remove_at(0)
	
	DebugConsole.console_ui.print_string.call_deferred("[b][color=red]ERROR: " + str + "[/color][/b]\n") # TEMP SOLUTION
	
	if print_to_godot_console:
		push_error(str)

#endregion

#region DUMP FILES

## Dump log with filter; default no filter.
## Filter predicate takes String and returns bool.
static func dump_to_file(dir_path: String, filter_pred: Callable = func(x): return true) -> void:
	## FIND UNIQUE FILE PATH BASED ON DATE
	var iteration: int = 0
	# var date_time: String = Time.get_datetime_string_from_system(false)
	var date_time: String = Time.get_date_string_from_system(false)
	# date_time = date_time.replace("-", "_")
	var file_path: String = ""
	
	while true:
		file_path = dir_path.path_join(log_file_name + "_" + date_time + "_" + str(iteration) + "." + log_file_extension)
		iteration += 1
		if not FileAccess.file_exists(file_path):
			break
	
	## OPEN FILE
	
	Logger.log("Dumping log to %s..." % file_path)
	
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	
	var new_file = FileAccess.open(file_path, FileAccess.WRITE)
	if not new_file:
		## ERROR opening new file!
		Logger.log_error("LOGGER: Attempt to open " + file_path + " failed.")
		return
	
	## STORE ENTRIES
	new_file.store_string(DebugConsole.game_name + " v" + DebugConsole.game_version + " by " + DebugConsole.studio_name + "\n")
	new_file.store_string("DebugConsole v%s | Debug Log\n" % DebugConsole.VERSION)
	new_file.store_string("Dumped at " + Time.get_datetime_string_from_system(false) + " | Maximum " + str(max_entries) + " entries before cutoff\n")
	new_file.store_string("-- BEGIN LOG --\n")

	var filtered_entries = entries.filter(filter_pred)
	for entry: String in filtered_entries:
		if strip_bbcode:
			new_file.store_string(strip_bbcode_tags(entry))
		else:
			new_file.store_string(entry)
	
	## CLOSE FILE
	new_file.store_string("-- END LOG --")
	new_file.close()
	
	Logger.log("Log successfully dumped to %s" % file_path)

#endregion

#region HELPERS

## Helper utility for generating predicate to filter for specific strings.
static func get_contains_str_pred(str: String) -> Callable:
	return func(s: String): return s.contains(str)

## Helper function for stripping BBCode tags
static var regex = RegEx.new()
static func strip_bbcode_tags(str: String) -> String:
	regex.compile("\\[.*?\\]")
	var text_without_tags = regex.sub(str, "", true)
	return text_without_tags

#endregion
