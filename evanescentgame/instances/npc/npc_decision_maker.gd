extends Node

const CLOCK_TIMER_UPDATE_TIME: float = 1 # NPC will check every this seconds for new node calls

var graph_data: DecisionTreeGraphData
var npc_name: String

var nodes_data: Array
var current_node: DecisionTreeNodeData

@onready var label = $Label

@onready var npc: NPC = get_parent() # THIS IS JUST FOR TESTING, THE ACTUAL END IMPLEMENTATION WILL BE DIFFERENT!

# Called when the node enters the scene tree for the first time.
func _ready():
	graph_data = npc.graph_data
	npc_name = npc.name
	
	if (!graph_data):
		print("No graph data!")
		return
	
	nodes_data = graph_data.nodes
	
	DTConditionManager.init_condition_map(npc_name, graph_data)
	
	for node in nodes_data:
		if (node.get_title() == "Start"):
			current_node = node
	
	if (!current_node):
		print("Start node not defined!")
	else:
		#call_node_function(current_node)
		start_timer()

func _process(delta):
	if (label):
		label.text = str(Time.get_ticks_msec() / 1000)

func call_node_function(node: DecisionTreeNodeData):
	var function_name = node.get_function_name()
	var parameters = node.get_parameters() # Need to parse these, as they don't actually work
	
	if (not npc.has_method(function_name)):
		print("Failed to call: ", function_name, " on NPC!")
		return
	
	var parameterTrueArray = []
	for parameter in parameters:
		
		var value
		match (parameter["type"]):
			0: # String
				value = parameter["value"]
			1: # Vector2
				var valueString: String = parameter["value"]
				var commaIndex = valueString.find(",")
				var x = float(valueString.substr(0, commaIndex))
				var y = float(valueString.substr(commaIndex + 1, -1)) # rest of the string
				value = Vector2(x ,y)
			2: # Location
				var location_manager = get_tree().get_nodes_in_group("locationManager")[0]
				value = location_manager.get_node(parameter["value"])
		
		parameterTrueArray.push_back(value)
	
	var callable = Callable(npc, function_name)
	print("Calling: ", callable)
	callable.callv(parameterTrueArray)


func start_timer():
	await get_tree().create_timer(CLOCK_TIMER_UPDATE_TIME).timeout
	var current_time = Time.get_ticks_msec() / 1000
	var next_function_time = current_node.get_next_function_call_time()
	
	if (current_time >= next_function_time):
		current_node = graph_data.get_next_node(current_node, npc_name)
		
		if (current_node):
			call_node_function(current_node)
	
	if (current_node):
		start_timer()
	else:
		print("No more nodes!")
