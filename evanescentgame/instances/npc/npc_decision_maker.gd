extends Node

const CLOCK_TIMER_UPDATE_TIME: float = 1 # NPC will check every this seconds for new node calls

var graph_data: DecisionTreeGraphData

var nodes_data: Array
var current_node: DecisionTreeNodeData

@onready var npc: NPC = get_parent() # THIS IS JUST FOR TESTING, THE ACTUAL END IMPLEMENTATION WILL BE DIFFERENT!

# Called when the node enters the scene tree for the first time.
func _ready():
	graph_data = npc.graph_data
	
	if (!graph_data):
		print("No graph data!")
		return
	
	nodes_data = graph_data.nodes
	
	for node in nodes_data:
		if (node.get_title() == "Start"):
			current_node = node
	
	if (!current_node):
		print("Start node not defined!")
	else:
		call_node_function(current_node)
		start_timer()

func call_node_function(node: DecisionTreeNodeData):
	var function_name = node.get_function_name()
	var parameters = node.get_parameters()
	
	var callable = Callable(npc, function_name)
	callable.callv(parameters)

func start_timer():
	await get_tree().create_timer(CLOCK_TIMER_UPDATE_TIME).timeout
	var current_time = Time.get_ticks_msec() / 1000
	var next_function_time = current_node.get_next_function_call_time()
	
	if (current_time > next_function_time):
		current_node = graph_data.get_next_node(current_node)
		
		if (current_node):
			call_node_function(current_node)
	
	if (current_node):
		start_timer()
	else:
		print("Node more nodes!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
