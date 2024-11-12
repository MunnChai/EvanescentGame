extends Node

var condition_map = {}
# The condition map looks something like this:
# {
# 	"Evan": {
#		"isButton1Pressed": true,
#		"isButton2Pressed": false
# 	},
#	"Wife": {
#		"isEvanSuperDead": true
#	}
# }

func init_condition_map(npc_name: String, graph_data: DecisionTreeGraphData):
	if (condition_map.has(npc_name)):
		printerr("Duplicate NPC in condition_map: ", npc_name, ", ignoring second npc graph_data")
	else:
		var npc_condition_map = {}
		
		var nodes: Array = graph_data.nodes
		for node: DecisionTreeNodeData in nodes:
			var alt_paths = node.get_alt_paths()
			for alt_path in alt_paths:
				var condition_name = alt_path["condition"]
				npc_condition_map[condition_name] = false
		
		condition_map[npc_name] = npc_condition_map

func set_condition(npc_name: String, condition_name: String, truth: bool):
	if (condition_map.has(npc_name)):
		var npc_condition_map = condition_map[npc_name]
		npc_condition_map[condition_name] = truth
		condition_map[npc_name] = npc_condition_map # NOT sure how godot handles references, this may be unnecessary
	else:
		var npc_condition_map = {
			condition_map: truth
		}
		condition_map[npc_name] = npc_condition_map

func get_condition(npc_name: String, condition_name: String):
	var npc_condition_map = condition_map[npc_name]
	var truth = npc_condition_map[condition_name]
	return truth
