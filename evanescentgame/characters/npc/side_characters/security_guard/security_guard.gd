class_name SecurityGuardNPC
extends NPC

func _physics_process(delta):
	if (is_possessed):
		if (player.is_input_active):
			handle_input(delta)
		
		handle_player_movement(delta)
	else:
		handle_npc_movement(delta)
	
	handle_animation()
