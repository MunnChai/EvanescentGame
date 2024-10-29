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

func get_next_node(current_node: DecisionTreeNodeData):
	var node_connections = []
	
	for connection in connections:
		if (connection["from_node"] == current_node.name):
			node_connections.append(connection)
	
	if (node_connections.size() == 0):
		return null
	
	# iterate through current_node conditions, if any of them are true, return the corresponding node
	
	var default_connection
	for connection in node_connections:
		if (connection["from_port"] == 0):
			default_connection = connection
	
	var next_node = get_node(default_connection["to_node"])
	
	return next_node
