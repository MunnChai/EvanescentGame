class_name Devil
extends NPC

## Interaction behaviour for Lady Devil
## Mainly dialogue

func on_player_interacted():
	signal_dialogue.emit("talking_to_devil")

func handle_npc_movement(delta: float):
	pass
