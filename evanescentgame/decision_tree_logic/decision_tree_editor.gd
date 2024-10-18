extends Control

const DECISION_TREE_NODE = preload("res://decision_tree_logic/decision_tree_graph/decision_tree_node.tscn")

@onready var graph: GraphEdit = $DecisionTreeGraph

# Called when the node enters the scene tree for the first time.
func _ready():
	# So the window will not close before finishing saving
	get_tree().set_auto_accept_quit(false)
	
	load_graph_data("res://decision_tree_logic/save_data/decision_tree_save_data.tres")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Saving graph data...")
		save_graph_data()
		print("Closing!")
		get_tree().quit()


# Graph Node Logic

func init_graph(graph_data: DecisionTreeGraphData):
	for node_data: DecisionTreeNodeData in graph_data.nodes:
		var node = DECISION_TREE_NODE.instantiate()
		node.init_node(node_data)
		graph.add_child(node)
	
	for connection in graph_data.connections:
		graph.connect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])

func add_new_node():
	var node_scene = DECISION_TREE_NODE.instantiate()
	graph.add_child(node_scene)


# Node Connection Requests

func on_connection_request(from_node, from_slot, to_node, to_slot):
	graph.connect_node(from_node, from_slot, to_node, to_slot)

func on_disconnection_request(from_node, from_slot, to_node, to_slot):
	graph.disconnect_node(from_node, from_slot, to_node, to_slot)

# Graph Saving Logic

func load_graph_data(file_name: String):
	if (ResourceLoader.exists(file_name)):
		var graph_data = ResourceLoader.load(file_name)
		if graph_data is DecisionTreeGraphData:
			init_graph(graph_data)
		else:
			# Error loading data
			pass
	else:
		# File not found
		pass

func save_graph_data():
	var graph_data = DecisionTreeGraphData.new()
	graph_data.connections = graph.get_connection_list()
	for node in graph.get_children():
		if (node is GraphNode):
			var node_data = DecisionTreeNodeData.new()
			node_data.name = node.name
			node_data.position_offset = node.position_offset
			node_data.data = node.data
			graph_data.nodes.append(node_data)
	
	var msg = ResourceSaver.save(graph_data, "res://decision_tree_logic/save_data/decision_tree_save_data.tres") 
	if (msg == OK):
		print("Saved Graph Data!")
	else:
		print("Error saving graph_data")
