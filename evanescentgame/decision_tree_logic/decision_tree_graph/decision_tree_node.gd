class_name DecisionTreeGraphNode
extends GraphNode

enum SlotType {
	DECISION = 0
}

var data = {}

@onready var title_edit = $Title

func _ready():
	set_slot(0, true, SlotType.DECISION, Color.WHITE, true, SlotType.DECISION, Color.GREEN)
	# add_title_bar()


func add_title_bar():
	var titlebar = get_titlebar_hbox()
	titlebar.remove_child(titlebar.get_child(0))
	var text_edit = $Description.duplicate()
	text_edit.custom_minimum_size = Vector2(size.x, 40)
	titlebar.add_child(text_edit)

func init_node(node_data: DecisionTreeNodeData):
	name = node_data.name
	position_offset = node_data.position_offset
	size = node_data.size
	
	data = node_data.data
	set_node_data()

func set_node_data():
	title_edit.text = data["title"]

func save_node_data():
	data["title"] = title_edit.text
