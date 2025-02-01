extends Node


func get_currently_possessed_npc_name() -> String:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if (!player):
		return ""
	
	if (!player.is_possessing):
		return ""
	
	return player.currently_possessed_npc.name

func is_currently_possessed_npc_holding(item_id: String) -> bool: 
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if (!player):
		return false
	
	if (!player.is_possessing):
		return false
	
	if (player.currently_possessed_npc.inventory_contains_item_id(item_id)):
		return true
	return false
