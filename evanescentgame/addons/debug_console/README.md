# Debug Console

**v0.0.2**

Introduces functionality for console input/output, logging, and custom commands for better Godot debugging and navigation during QA testing.

## Usage

The console is automatically added to the root of your Godot scene at runtime. 

To open the console, use the `F1` key. If your computer has functionality that triggers when `F1` is pressed (such as on a Macbook), use `fn + F1`.

## Configuration

DebugConsole pulls all user configuration out of the `CONFIG.tres` file located at `res://addons/debug_console/CONFIG.tres`. Edit or replace this file to change the configuration details. 

**Note that the configuration file MUST be named `CONFIG.tres` and be located at `res://addons/debug_console/CONFIG.tres`.**

### Configuration Details

Highlight over each config option to get a tooltip that describes that field's purpose/effect on the DebugConsole.

## Logging

**RECOMMENDATION: If using the log dump files feature, consider adding whatever directory the logs are stored in to be in your `.gitignore`. This prevents the build-up of log files in your project's repository.**

Currently, there is a static class called `Logger`

Log messages by calling `Logger.log("message")` from anywhere. There are also `Logger.log_warning("warning")` and `Logger.log_error("error")`.

The configuration details for the `Logger` are found under the `Logging` heading of `CONFIG.tres`.

Dumping the log to a file can be done via calling `dump <destination-directory>` in the console. If the destination directory is left blank, the log is dumped to the default directory specified in `CONFIG.tres`.

The shortcut, `F3` or `fn + F3` (depending on system), is equivalent to the behaviour of calling the `dump` command with no arguments.

## Commands

The Debug Console comes with a few built-in commands.

- `help`
	
	Prints a list of commands and their short help entries.
- `cmdlist`

	Prints a list of all currently registered commands to the console.
- `clear`

	Clears the console.
- `close` 

	Closes the console the same way that the CLOSE CONSOLE button works.
- `quit` 

	Quits the game using `get_tree().quit()`
- `pause [true/false]` 

	Sets the `paused` flag of the current `get_tree()` SceneTree to the argument. If no argument, toggles the `paused` flag.
- `dump [destination-dir]`

	Dumps the current log, with no filter, to a file at the destination directory with the name `<log_file_name_prefix>_<iteration>.txt`. If no `[destination-dir]` is provided, the default directory is used.

## Registering Custom Commands

The console's backend uses a command registry. To register your own commands from your codebase:

1. Create a closure of `Callable` type (a function, anonymous function, lambda) which takes one parameter of type `PackedStringArray`. These are your command's arguments.
2. Define your command's logic and behaviour within the Calleable's body.
3. Call `DebugConsole.register()` with your new command's name (e.g. the identifying keyword) and your Callable to register it. For example: 

	```
	DebugConsole.register("hello1", 
		func (args: PackedStringArray): print("hi!"))
	```
	This registers a command called `hello1` which prints `hi!` to the regular Godot console every time it is executed via the console.

**NOTE: The registration only persists per runtime. This means that your command(s) should be added at the loading stage of your game.**

## Unregistering

To remove a command from the registry, use `DebugConsole.unregister()` with your command's name. e.g. `unregister("hello1")`.

## Help Entries

In the call to `register()`, you can include two more arguments for a short help blurb and a long help description entry. For example:

```
DebugConsole.register("hello1", hello_cmd, "Prints hi!", """Usage: hello1
	Prints hi! to the Godot Output console.""")
```

Which registers `hello1` with a short help message and a detailed help entry.

The short message shows up next to the command name when the `help` command is called.

The longer entry shows up when `help` is called with the command name as the argument. E.g. `help hello1`.

## Registering DebugConsoleCommand Objects

Instead of calling `register` with all four arguments (name, callable, short blurb, long entry), you can also create a `DebugConsoleCommand` object. Then, you can assign the latter three arguments (callable, short blurb, long entry). 

To register the object, simply call `DebugConsole.register_cmd(name, command_object)` with your command's name keyword and DebugConsoleCommand instance.

# TODO

Here is a list of features that are planned:
- Stack trace in the Logger
- Multiple Logger instances
- Separate console log and event log for easier filtering/selection.
