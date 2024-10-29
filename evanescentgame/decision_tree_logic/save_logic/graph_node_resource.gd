class_name DecisionTreeNodeData

extends Resource

@export var name: String
@export var position_offset: Vector2
@export var size: Vector2 = Vector2(180, 100)
@export var data = {
	"title": "", # Title of node, doesn't really matter
	"description": "", # Short description of what occurs during this node
	"npc_name": "", # Which NPC is the function called on? 
	"function_name": "", # Which function should we call on the NPC?
	"parameters": [], # With what parameters?
	"next_function_time": 0, # Time, in seconds
	"alt_paths": [] # What alternate nodes can be reached from this point? 
}

func get_title() -> String:
	return data["title"]

func get_description() -> String:
	return data["description"]

func get_npc_name() -> String:
	return data["npc_name"]

func get_function_name() -> String:
	return data["function_name"]

func get_next_function_call_time() -> float: 
	return data["next_function_time"]

func get_parameters() -> Array:
	return data["parameters"]
