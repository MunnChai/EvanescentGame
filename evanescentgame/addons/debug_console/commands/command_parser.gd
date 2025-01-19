class_name DebugConsoleCommandParser

## COMMAND PARSER
## An instance of a parser that can take string inputs
## and call any registered commands with args



func _init() -> void:
	_register_default_commands()

func _register_default_commands() -> void:
	## COMMAND LIST
	var command_list_callable: Callable = func (args: PackedStringArray):
		var output = ""
		for command in command_dictionary:
			if output.is_empty():
				output += command
			else:
				output += ", %s" % command
		Logger.log(output)
	register("command-list", command_list_callable)

#region REGISTRY

## Keys are Strings, corresponding to valid command keywords.
## Values are Callables, corresponding to actual command logic.
var command_dictionary: Dictionary = {}

## Registers a command with name, pointing to the corresponding callable.
## If command already exists, REPLACES existing entry.
## Callable should be a function that takes PackedStringArray (Args)
## and does not return anything (all side effects only).
func register(name: String, callable: Callable) -> void:
	command_dictionary[name] = callable

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
	if dictionary_entry is Callable:
		# Logger.log("Command found: " + command + ", calling with arguments " + str(args))
		dictionary_entry.call(args)
	else:
		Logger.log_error("Unknown command: " + command)

#endregion
