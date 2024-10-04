extends StaticBody2D

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

func on_player_interacted():
	if (player.currently_possessed_npc.currently_held_item):
		$CollisionShape2D.disabled = true
		$Sprite2D.visible = false
