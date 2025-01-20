class_name DebugConsoleCommandParser

## COMMAND PARSER
## An instance of a parser that can take string inputs
## and call any registered commands with args



func _init() -> void:
	_register_default_commands()

func _register_default_commands() -> void:
	## HELP
	var help_cmd: Callable = func (args: PackedStringArray):
		if len(args) < 1:
			## REGULAR HELP
			var output = "Type [b]help [cmd_name][/b] for a more detailed entry\n"
			for command in command_dictionary:
				var line = ""
				if command_dictionary[command].get_short_help_desc().is_empty():
					line = "[b]%s[/b]" % command + ": <no blurb provided>"
				else:
					line = "[b]%s[/b]" % command + ": " + command_dictionary[command].get_short_help_desc()
				if output.is_empty():
					output += line
				else:
					output += "\n%s" % line
			Logger.log(output)
		else:
			if args[0] in command_dictionary:
				if command_dictionary[args[0]].get_long_help_desc().is_empty():
					Logger.log("[b]%s[/b]" % args[0] + " has no detailed help entry.")
				else:
					Logger.log("[b]%s[/b]" % args[0] + "\n" + command_dictionary[args[0]].get_long_help_desc())
			else:
				Logger.log_error("help not found for %s: not a registered command" % args[0])
	register("help", help_cmd, "Lists help for all registered commands", """Usage: help [cmd_name]
	If no cmd_name is specified, prints a list of commands and their short descriptions.
	If cmd_name, prints the detailed help entry for cmd_name.""")

	## COMMAND LIST
	var cmdlist_cmd: Callable = func (args: PackedStringArray):
		var output = ""
		for command in command_dictionary:
			if output.is_empty():
				output += command
			else:
				output += ", %s" % command
		Logger.log(output)
	register("cmdlist", cmdlist_cmd, "Lists all currently registered commands", """Usage: cmdlist
	Lists all currently registered commmands in a comma-separated list.""")

#region REGISTRY

## Keys are Strings, corresponding to valid command keywords.
## Values are DebugConsoleCommand objects,
## which encapsulate the Callable (actual logic) and short and long help blurbs.
var command_dictionary: Dictionary = {}

## SHORT BLURBS should be one sentence with no punctuation
## LONG DESCRIPTION should start with a USAGE: <command format> line
## then continue with indented lines in regular English punctuation describing behaviour.

## Registers a command with name, pointing to the corresponding callable.
## If command already exists, REPLACES existing entry.
## Callable should be a function that takes PackedStringArray (Args)
## and does not return anything (all side effects only).
## Can supply help blurbs, but not required.
func register(name: String, callable: Callable, short_help_desc: String = "", long_help_desc: String = "") -> void:
	var cmd_obj: DebugConsoleCommand = DebugConsoleCommand.new(callable, short_help_desc, long_help_desc)
	command_dictionary[name] = cmd_obj
## Registers a command object already constructed.
func register_cmd(name: String, cmd: DebugConsoleCommand):
	command_dictionary[name] = cmd

## Unregisters command with given name, if it exists.
func unregister(name: String) -> void:
	command_dictionary.erase(name)

#endregion

#region PARSING

## Parses given input string
## If a command is found, executes the command
## otherwise, log an error for unknown command
func parse_and_try_execute(input_string: String) -> void:
	## SPLIT INPUT STRING INTO SEGMENTS
	var space_separated_strings: PackedStringArray = input_string.strip_edges().split(" ", false)
	if len(space_separated_strings) == 0:
		Logger.log_error("Attempted to parse command, but found no command or arguments.")
		return
	
	## ISOLATE COMMAND AND ARGUMENTS
	var command: String = space_separated_strings[0]
	space_separated_strings.remove_at(0)
	var args: PackedStringArray = space_separated_strings
	
	## TRY CALL CORRESPONDING COMMAND
	Logger.log("> %s" % input_string)
	var dictionary_entry = command_dictionary.get(command, null)
	if dictionary_entry is DebugConsoleCommand:
		# Logger.log("Command found: " + command + ", calling with arguments " + str(args))
		dictionary_entry.callable.call(args)
	else:
		Logger.log_error("Unknown command: " + command)

#endregion
