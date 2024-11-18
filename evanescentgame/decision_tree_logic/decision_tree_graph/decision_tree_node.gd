class_name DecisionTreeGraphNode
extends GraphNode

const DEFAULT_SLOT_INDEX = 7
const FUNCTION_CONTAINER = preload("./node_components/function_container.tscn")

enum SlotType {
	DECISION = 0
}

var data = {}

@onready var title_edit = $Title
@onready var description = $Description
@onready var functions_container = $FunctionsContainer
@onready var function_time = $FunctionTime

var alt_path_hboxes: Array = []

func _ready():
	# Add default path slot
	set_slot(DEFAULT_SLOT_INDEX, true, SlotType.DECISION, Color.WHITE, true, SlotType.DECISION, Color.GREEN)





# Adding alternate paths

func add_slot(condition_name: String = "Condition" + str(get_output_port_count())):
	# Get slot index
	var slot_index = DEFAULT_SLOT_INDEX + 1 + get_output_port_count()
	
	# Create new container
	var path_hbox = HBoxContainer.new()
	
	# Create button for removing container and slot
	var remove_button = Button.new()
	remove_button.text = "RemovePath"
	remove_button.pressed.connect(on_path_remove_button_pressed.bind(path_hbox))
	remove_button.modulate = Color.GREEN
	
	# Create slot
	set_slot(slot_index, false, SlotType.DECISION, Color.WHITE, true, SlotType.DECISION, Color.RED)
	
	# Create text box for condition
	var condition_text_edit = TextEdit.new()
	condition_text_edit.custom_minimum_size = Vector2(0, 40)
	condition_text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	condition_text_edit.text = condition_name;
	
	# Add remove button and text box to container
	path_hbox.add_child(remove_button)
	path_hbox.add_child(condition_text_edit)
	
	# Add container to self and append it to an array for easy access (when saving)
	add_child(path_hbox)
	alt_path_hboxes.append(path_hbox)

func on_path_remove_button_pressed(path_hbox: HBoxContainer):
	var children = get_children()
	var index = children.find(path_hbox)
	
	# PSEUDOCODE OF BELOW:
	# Clear last slot
	# For each connection to this node, 
	# if the from_port is equal to index, delete connection
	# if the from_port is larger than index, subtract 1 from from_port
	clear_slot(DEFAULT_SLOT_INDEX + get_output_port_count())
	var graph_edit: GraphEdit = get_parent()
	var all_connections = graph_edit.get_connection_list()
	var this_connections: Array
	for connection in all_connections:
		if (connection["from_node"] == name):
			this_connections.append(connection)
	
	this_connections.sort_custom(sort_by_port)
	
	# If there is a connection at this slot, remove the connection
	for connection in this_connections:
		if (connection["from_port"] == index - DEFAULT_SLOT_INDEX - 1):
			graph_edit.disconnection_request.emit(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
			break
	
	# Move any connections below this slot UP
	for connection in this_connections:
		if (connection["from_port"] > index - DEFAULT_SLOT_INDEX - 1):
			graph_edit.disconnection_request.emit(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
			graph_edit.connection_request.emit(connection["from_node"], connection["from_port"] - 1, connection["to_node"], connection["to_port"])
	
	alt_path_hboxes.erase(path_hbox)
	path_hbox.queue_free()


func sort_by_port(connection1: Dictionary, connection2: Dictionary):
	if (connection1["from_port"] < connection2["from_port"]):
		return true
	return false


# Adding functions
func add_function():
	var function_container = FUNCTION_CONTAINER.instantiate()
	
	functions_container.add_child(function_container)


# Saving and loading nodes

func init_node(node_data: DecisionTreeNodeData):
	name = node_data.name
	position_offset = node_data.position_offset
	size = node_data.size
	
	data = node_data.data
	set_node_data()

func set_node_data():
	title_edit.text = data["title"]
	description.text = data["description"]
	function_time.value = data["next_function_time"]
	
	for function in data["functions"]:
		var function_container = FUNCTION_CONTAINER.instantiate()
		functions_container.add_child(function_container)
		
		function_container.function_name.text = function["function_name"]
		
		for parameter in function["parameters"]:
			function_container.add_parameter(parameter["type"], parameter["value"])
	
	for path in data["alt_paths"]:
		add_slot(path["condition"])


func save_node_data():
	data["title"] = title_edit.text
	data["description"] = description.text
	data["next_function_time"] = function_time.value
	
	var function_array = []
	for function_container: FunctionContainer in functions_container.get_children():
		var function_data = {}
		function_data["function_name"] = function_container.function_name.text
	
		var parameter_array = []
		for param_hbox in function_container.param_hboxes:
			var param_type = param_hbox.get_child(1) # HARD CODED, BE CAREFUL HERE
			var param_text = param_hbox.get_child(2)
			var dict = {
				"type": param_type.get_selected_id(),
				"value": param_text.text
			}
			parameter_array.append(dict)
		function_data["parameters"] = parameter_array
		
		function_array.append(function_data)
	data["functions"] = function_array
	
	var alt_path_array = []
	for alt_path in alt_path_hboxes:
		var condition_text_edit = alt_path.get_child(1) # HARD CODED, BE CAREFUL HERE
		var dict = {
			"condition": condition_text_edit.text
		}
		alt_path_array.append(dict)
	
	data["alt_paths"] = alt_path_array
