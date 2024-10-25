class_name DecisionTreeGraphNode
extends GraphNode

const DEFAULT_SLOT_INDEX = 7

enum SlotType {
	DECISION = 0
}

var data = {}

@onready var title_edit = $Title
@onready var description = $Description
@onready var npc_name = $NPCName
@onready var function_name = %FunctionName
@onready var param_container = %ParamContainer

var alt_path_hboxes: Array = []

func _ready():
	set_slot(DEFAULT_SLOT_INDEX, true, SlotType.DECISION, Color.WHITE, true, SlotType.DECISION, Color.GREEN)

func add_slot(condition_name: String = "Condition" + str(get_output_port_count())):
	var slot_index = DEFAULT_SLOT_INDEX + 1 + get_output_port_count()
	
	var path_hbox = HBoxContainer.new()
	
	var remove_button = Button.new()
	remove_button.text = "RemovePath"
	remove_button.pressed.connect(on_remove_button_pressed.bind(path_hbox))
	
	set_slot(slot_index, false, SlotType.DECISION, Color.WHITE, true, SlotType.DECISION, Color.RED)
	#print("Adding at slot ", slot_index - DEFAULT_SLOT_INDEX - 1)
	
	var condition_text_edit = TextEdit.new()
	condition_text_edit.custom_minimum_size = Vector2(0, 40)
	condition_text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	condition_text_edit.text = condition_name;
	
	path_hbox.add_child(remove_button)
	path_hbox.add_child(condition_text_edit)
	add_child(path_hbox)
	alt_path_hboxes.append(path_hbox)

func on_remove_button_pressed(path_hbox: HBoxContainer):
	var children = get_children()
	var index = children.find(path_hbox)
	path_hbox.queue_free()
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
	#print("ThisNodeConnections: ", this_connections)
	
	#print("Slot removing index: ", index - DEFAULT_SLOT_INDEX - 1)
	
	this_connections.sort_custom(sort_by_port)
	
	#print("Sorted connections: ", this_connections)
	
	# If there is a connection at this slot, remove the connection
	for connection in this_connections:
		if (connection["from_port"] == index - DEFAULT_SLOT_INDEX - 1):
			graph_edit.disconnection_request.emit(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
			#print("Removing slot: ", connection["from_port"])
			break
	
	# Move any connections below this slot UP
	for connection in this_connections:
		if (connection["from_port"] > index - DEFAULT_SLOT_INDEX - 1):
			graph_edit.disconnection_request.emit(connection["from_node"], connection["from_port"], connection["to_node"], connection["to_port"])
			graph_edit.connection_request.emit(connection["from_node"], connection["from_port"] - 1, connection["to_node"], connection["to_port"])
			#print("Moving slot: ", connection["from_port"], " to ", connection["from_port"] - 1)
	
	alt_path_hboxes.erase(path_hbox)


func sort_by_port(connection1: Dictionary, connection2: Dictionary):
	if (connection1["from_port"] < connection2["from_port"]):
		return true
	return false


func add_title_bar():
	var titlebar = get_titlebar_hbox()
	titlebar.remove_child(titlebar.get_child(0))
	var text_edit = $Description.duplicate()
	text_edit.custom_minimum_size = Vector2(0, 40)
	titlebar.add_child(text_edit)

func init_node(node_data: DecisionTreeNodeData):
	name = node_data.name
	position_offset = node_data.position_offset
	size = node_data.size
	
	data = node_data.data
	set_node_data()

func set_node_data():
	title_edit.text = data["title"]
	description.text = data["description"]
	npc_name.text = data["npc_name"]
	function_name.text = data["function_name"]
	
	for parameter in data["parameters"]:
		pass
	
	var i = 0
	for path in data["alt_paths"]:
		add_slot(path["condition"])
		#print("Adding path: ", path)

#@export var data = {
	#"title": "",
	#"description": "",
	#"function_name": "",
	#"alt_paths": []
#}


func save_node_data():
	data["title"] = title_edit.text
	data["description"] = description.text
	data["npc_name"] = npc_name.text
	data["function_name"] = function_name.text
	data["parameters"] = [] # TODO: CHANGE THIS
	 
	var alt_path_array = []
	for alt_path in alt_path_hboxes:
		var condition_text_edit = alt_path.get_child(1)
		var dict = {
			"condition": condition_text_edit.text
		}
		alt_path_array.append(dict)
	
	data["alt_paths"] = alt_path_array
