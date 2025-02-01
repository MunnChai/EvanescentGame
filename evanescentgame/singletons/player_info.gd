extends Node


func get_currently_possessed_npc_name() -> String:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if (!player):
		return ""
	
	if (!player.is_possessing):
		return ""
	
	print(player.currently_possessed_npc.name)
	return player.currently_possessed_npc.name
