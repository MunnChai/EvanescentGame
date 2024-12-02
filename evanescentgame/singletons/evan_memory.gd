extends Node

# Evan's "Memory"
# This is mostly used for dialogue, to add variation and branching dialogue and whatnot. 
# After learning certain information, Evan's memory will  


var memory_dictionary: Dictionary = {}


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
