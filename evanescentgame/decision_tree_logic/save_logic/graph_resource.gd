class_name DecisionTreeGraphData
extends Resource

@export var connections: Array
@export var nodes: Array

func get_node(node_name: String) -> DecisionTreeNodeData:
	for node in nodes:
		if (node.name == node_name):
			return node
	
	return null

func get_node_connections(node: DecisionTreeNodeData) -> Array:
	var node_connections = []
	for connection in connections:
		if (connection["from_node"] == node.name):
			node_connections.append(connection)
	
	return node_connections

func get_next_node(current_node: DecisionTreeNodeData, npc_name: String):
	var node_connections = []
	
	for connection in connections:
		if (connection["from_node"] == current_node.name):
			node_connections.append(connection)
	
	if (node_connections.size() == 0):
		return null
	
	# iterate through current_node conditions, if any of them are true, return the corresponding node
	var alt_paths = current_node.get_alt_paths()
	for i in alt_paths.size():
		# Get condition_name
		var alt_path = alt_paths[i]
		var condition_name = alt_path["condition"]
		
		# Get condition truthness from respective NPC condition manager
		var should_take_path = DTConditionManager.get_condition(npc_name, condition_name)
		
		# Return node if truthness is true
		if (should_take_path):
			for connection in node_connections:
				if (connection["from_port"] == i + 1):
					var next_node = get_node(connection["to_node"])
					return next_node
		# Else continue
	
	var default_connection
	for connection in node_connections:
		if (connection["from_port"] == 0):
			default_connection = connection
	
	var next_node = get_node(default_connection["to_node"])
	
	return next_node
