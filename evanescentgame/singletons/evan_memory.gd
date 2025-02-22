extends Node

# Evan's "Memory"
# This is mostly used for dialogue, to add variation and branching dialogue and whatnot. 
# After learning certain information, Evan's memory will  


var memory_dictionary: Dictionary = {}

## DEBUG COMMANDS
func _setup_debug() -> void:
	var memory_cmd = func (args: PackedStringArray):
		if len(args) < 1:
			Logger.log("memory expects subcommand: lock, unlock, flags, clear")
			return
		var sub_cmd := args[0]
		match sub_cmd:
			"lock":
				if len(args) < 2:
					Logger.log_error("memory lock needs at least one flag: memory lock <flag1> <flag2> ...")
				else:
					var remaining_args := args.slice(1)
					for arg in remaining_args:
						set_memory(arg, false)
						Logger.log("Locked Memory flag: " + arg + ".")
			"unlock":
				if len(args) < 2:
					Logger.log_error("memory unlock needs at least one flag: memory unlock <flag1> <flag2> ...")
				else:
					var remaining_args := args.slice(1)
					for arg in remaining_args:
						set_memory(arg, true)
						Logger.log("Unlocked Memory flag: " + arg + ".")
			"flags": ## PRINT FLAGS
				Logger.log("Memory Unlock Flags:")
				var output := ""
				var dict = get_memory_dict()
				for flag in dict:
					var pair: String = flag + ": " + str(dict[flag])
					if output.is_empty():
						output += pair
					else:
						output += "\n%s" % pair
				if not output.is_empty():
					Logger.log(output)
			"clear": ## CLEAR FLAGS
				clear_memory()
				Logger.log("Cleared Memory Unlock Flags.")
	
	DebugConsole.register.call_deferred("memory", memory_cmd)

func _ready() -> void:
	_setup_debug()



func set_memory(memory_name: String, boolean: bool) -> void:
	memory_dictionary[memory_name] = boolean

func get_memory(memory_name) -> bool:
	if (memory_dictionary.has(memory_name)):
		return memory_dictionary[memory_name]
	
	return false

func clear_memory():
	memory_dictionary = {}

func set_memory_dict(dictionary: Dictionary) -> void: 
	memory_dictionary = dictionary

func get_memory_dict() -> Dictionary:
	return memory_dictionary
