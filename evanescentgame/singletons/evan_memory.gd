extends Node

# Evan's "Memory"
# This is mostly used for dialogue, to add variation and branching dialogue and whatnot. 
# After learning certain information, Evan's memory will  


var memory_dictionary: Dictionary = {}


func _ready() -> void:
	## DEBUG COMMANDS
	var unlock_command = func(args: PackedStringArray):
		if len(args) < 1:
			Logger.log("Need memory flag ID(s) to unlock.")
		else:
			for arg in args:
				set_memory(arg, true)
				Logger.log("Unlocked memory flag " + arg + ".")
	var lock_command = func(args: PackedStringArray):
		if len(args) < 1:
			Logger.log("Need memory flag ID(s) to lock.")
		else:
			for arg in args:
				set_memory(arg, false)
				Logger.log("Locked memory flag " + arg + ".")
	DebugConsole.register.call_deferred("munlock", unlock_command)
	DebugConsole.register.call_deferred("mlock", lock_command)
	DebugConsole.register.call_deferred("mclear", func(args): 
		clear_memory()
		Logger.log("Cleared Evan's memory."))
	DebugConsole.register.call_deferred("memory", func(args):
		Logger.log("Evan's Memory State:")
		var dict = get_memory_dict()
		for memory in dict:
			Logger.log(memory + ": " + str(dict[memory])))



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
