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
	"alt_paths": [] # What alternate nodes can be reached from this point? 
}
