extends Node

## DEBUG CONSOLE GLOBAL
## Autoload script for DebugConsole



const VERSION = "0.0.2" # DEBUG CONSOLE PLUGIN VERSION

#region PUBLIC INTERFACE

## Easy-access public "forwarders" for the registry
func register(name: String, callable: Callable, short_help_desc: String = "", long_help_desc: String = "") -> void:
	command_parser.register(name, callable, short_help_desc, long_help_desc)
func unregister(name: String) -> void:
	command_parser.unregister(name)
func register_cmd(name: String, cmd: DebugConsoleCommand) -> void:
	command_parser.register_cmd(name, cmd)

#region CONFIG

## Always loads the CONFIG file from the plugin folder
## Change this path if another CONFIG file is used
const CONFIG: DebugConsoleConfig = preload("res://addons/debug_console/CONFIG.tres")

## Relevant information pulled from PROJECT SETTINGS
@onready var game_name = ProjectSettings.get_setting("application/config/name")
@onready var game_version = _get_game_version()
func _get_game_version() -> String:
	var version: String = ProjectSettings.get_setting("application/config/version").strip_edges()
	if version.is_empty():
		return "<no version>"
	if version.substr(0, 1) == "v":
		return version.substr(1)
	return version

@onready var studio_name = CONFIG.studio_name

#endregion

#region SETUP

const CONSOLE_UI_SCENE = preload("./console_ui/console_ui.tscn")

var console_ui: ConsoleUI
var command_parser: DebugConsoleCommandParser

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Always processing, debug is.
	
	setup_command_parser()
	setup_console_ui()
	register_default_commands()
	
	Logger.log.call_deferred(game_name + " v" + game_version + " by " + studio_name)
	Logger.log.call_deferred("DebugConsole v%s by felixrl" % VERSION)
	Logger.log.call_deferred("Debugging started at %s\n" % Time.get_datetime_string_from_system(false))
	# Logger.log.call_deferred("Dumped at " + Time.get_datetime_string_from_system(false) + " | Maximum " + str(Logger.MAX_ENTRIES) + " lines before cutoff")
	# Logger.log.call_deferred("-- BEGIN LOG --\n")
	Logger.log.call_deferred("For a list of commands, type [b]cmdlist[/b] or [b]help[/b].")

func setup_command_parser() -> void:
	command_parser = DebugConsoleCommandParser.new()

func setup_console_ui() -> void:
	console_ui = CONSOLE_UI_SCENE.instantiate()
	get_tree().root.add_child.call_deferred(console_ui) # Wait until root is done init...
	
	## WIRE UP COMMAND SUBMISSION
	console_ui.command_submitted.connect(command_parser.parse_and_try_execute)
	
	## WIRE UP LOGGER
	## ??? Should logger be instanced?

func register_default_commands() -> void:
	## CLEAR CONSOLE
	var clear_cmd: Callable = func (args: PackedStringArray):
		console_ui.clear()
		Logger.log("Console cleared.\n")
	command_parser.register("clear", clear_cmd, "Clears the console", """Usage: clear
	Clears the console and prints \"Console cleared.\"""")
	
	## TOGGLE PAUSE/SET PAUSE
	var pause_cmd: Callable = func(args: PackedStringArray):
		if len(args) < 1:
			get_tree().paused = not get_tree().paused
			if get_tree().paused:
				Logger.log("[b]Game paused.[/b] Type pause to unpause.")
			else:
				Logger.log("[b]Game unpaused.[/b] Type pause to pause.")
		elif (not args[0] == "true" and not args[0] == "false"):
			## Invalid argument
			Logger.log_error("Invalid argument: pause expects either true or false.")
		else:
			if args[0] == "true":
				get_tree().paused = true
				Logger.log("[b]Game paused.[/b] Type pause to unpause.")
			elif args[0] == "false":
				get_tree().paused = false
				Logger.log("[b]Game unpaused.[/b] Type pause to pause.")
	command_parser.register("pause", pause_cmd, "Controls pause state of the tree", """Usage: pause [true/false]
	If no argument, toggles paused state of the SceneTree.
	If given true or false, sets paused state of the SceneTree to given value.""")
	
	## CLOSE CONSOLE
	command_parser.register("close", func(args): console_ui.close(), "Closes the console", """Usage: close
	Closes the console in the same manner as the Close Console button.""")
	## QUIT GAME
	command_parser.register("quit", func(args): get_tree().quit(), "Quits the application", """Usage: quit
	Calls quit() on the current SceneTree.""")
	
	## DUMP LOG
	var dump_cmd: Callable = func (args: PackedStringArray):
		if len(args) < 1 or args[0].is_empty():
			Logger.dump_to_file(CONFIG.default_logs_directory_path)
		else:
			Logger.dump_to_file(args[0])
	command_parser.register("dump", dump_cmd, "Dumps the console log to a file", """Usage: dump [destination_directory]
	If no destination is provided, dumps a log file with all console entries to the CONFIG's default logs folder.
	If a destination is provided, attempts to dump a log file to the given folder path.""")

#endregion

#region INPUT HANDLING

const CONSOLE_TOGGLE_KEY = KEY_F1
const DUMP_LOG_KEY = KEY_F3

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(CONSOLE_TOGGLE_KEY) and just_pressed:
		console_ui.toggle()
	if Input.is_key_pressed(DUMP_LOG_KEY) and just_pressed:
		Logger.log("F3 shortcut pressed")
		Logger.dump_to_file(CONFIG.default_logs_directory_path)

#endregion
