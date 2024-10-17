extends GraphNode

enum SlotType {
	DECISION = 0
}

var data

func _ready():
	set_slot(0, true, SlotType.DECISION, Color.WHITE, true, SlotType.DECISION, Color.GREEN)
	var titlebar = get_titlebar_hbox()
	titlebar.remove_child(titlebar.get_child(0))
	var text_edit = TextEdit.new()
	text_edit.size_flags_horizontal = Control.SIZE_FILL
	text_edit.size_flags_vertical = Control.SIZE_FILL
	text_edit.custom_minimum_size = Vector2(size.x, 40)
	titlebar.add_child(text_edit)
	

func _on_delete_request():
	print("DELETING!")

func init_node(node_data: DecisionTreeNodeData):
	name = node_data.name
	position_offset = node_data.position_offset
	data = node_data.data
