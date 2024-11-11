extends Control

const DECISION_TREE_NODE = preload("res://decision_tree_logic/decision_tree_graph/decision_tree_node.tscn")

@onready var graph: GraphEdit = $DecisionTreeGraph

@export var graph_data_path: String


# General node functions

func _ready():
	# So the window will not close before finishing saving
	get_tree().set_auto_accept_quit(false)
	
	# So you can disconnect nodes from either end of the connection
	graph.add_valid_left_disconnect_type(DecisionTreeGraphNode.SlotType.DECISION)
	
	# Load graph data from save resource
	load_graph_data(graph_data_path)



func _process(delta):
	if (Input.is_action_just_pressed("ui_undo")):
		handle_undo()
	elif (Input.is_action_just_pressed("ui_redo")):
		handle_redo()

func _notification(what):
	# Runs on close window request
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		
		save_graph_data()
		print("Closing!")
		get_tree().quit()






# Graph Node Logic

# Adds nodes to graph and initializes them with their respective node data
# Adds connections to graph
func init_graph(graph_data: DecisionTreeGraphData):
	for node_data: DecisionTreeNodeData in graph_data.nodes:
		var node = DECISION_TREE_NODE.instantiate()
		graph.add_child(node)
		node.init_node(node_data)
	
	for connection in graph_data.connections:
		graph.connect_node(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])

# Adds a node to the graph and initializes it with a new node data resource
func add_new_node():
	var node_scene = DECISION_TREE_NODE.instantiate()
	
	undoRedo.create_action("Added Node: " + node_scene.name)
	undoRedo.add_do_method(graph.add_child.bind(node_scene))
	undoRedo.add_undo_method(graph.remove_child.bind(node_scene))
	undoRedo.commit_action()
	
	var node_data = DecisionTreeNodeData.new()
	node_data.name = "GraphNode" + str(graph.get_children().size() + 1)
	node_scene.init_node(node_data)





# Undo Redo Logic

var undoRedo = UndoRedo.new()

func handle_undo():
	if (undoRedo.has_undo()):
		print("Undo: ", undoRedo.get_action_name(undoRedo.get_current_action()))
		undoRedo.undo()

func handle_redo():
	if (undoRedo.has_redo()):
		print("Redo: ", undoRedo.get_current_action_name())
		undoRedo.redo()

# Node Requests

func on_connection_request(from_node: String, from_slot: int, to_node: String, to_slot: int):
	undoRedo.create_action("Connected Nodes: " + from_node + ", " + to_node)
	undoRedo.add_do_method(graph.connect_node.bind(from_node, from_slot, to_node, to_slot))
	undoRedo.add_undo_method(graph.disconnect_node.bind(from_node, from_slot, to_node, to_slot))
	undoRedo.commit_action()
	#print("Connected node ", from_node, " slot ", from_slot, ", to ", to_node, " slot ", to_slot)

func on_disconnection_request(from_node: String, from_slot: int, to_node: String, to_slot: int):
	undoRedo.create_action("Disconnected Nodes: " + from_node + ", " + to_node)
	undoRedo.add_do_method(graph.disconnect_node.bind(from_node, from_slot, to_node, to_slot))
	undoRedo.add_undo_method(graph.connect_node.bind(from_node, from_slot, to_node, to_slot))
	undoRedo.commit_action()

func _delete_nodes_request(nodes: Array):
	var node_names: Array = nodes.duplicate()
	var node_name_string: String = ""
	for node_name in node_names:
		node_name_string += node_name + ", "
	
	undoRedo.create_action("Deleted Nodes: " + node_name_string)
	for node_name in nodes:
		var node
		for child in graph.get_children():
			if (child.name == node_name):
				node = child
		
		undoRedo.add_do_method(graph.remove_child.bind(node))
		undoRedo.add_undo_method(graph.add_child.bind(node))
		undoRedo.add_undo_reference(node)
	undoRedo.commit_action()




# Graph Saving Logic

func load_graph_data(file_path: String):
	if (ResourceLoader.exists(file_path)):
		var graph_data = ResourceLoader.load(file_path)
		if graph_data is DecisionTreeGraphData:
			init_graph(graph_data)
	else:
		print("Graph Data file not found: ", file_path)

func save_graph_data():
	print("Saving graph data...")
	var graph_data = DecisionTreeGraphData.new()
	
	for node in graph.get_children():
		if (node is DecisionTreeGraphNode):
			node.save_node_data()
			var node_data = DecisionTreeNodeData.new()
			node_data.name = node.name
			node_data.position_offset = node.position_offset
			node_data.data = node.data
			node_data.size = node.size
			graph_data.nodes.append(node_data)
	
	graph_data.connections = graph.get_connection_list()
	
	var msg = ResourceSaver.save(graph_data, graph_data_path) 
	if (msg == OK):
		print("Saved Graph Data!")
	else:
		print("Error saving graph_data: ", msg)
