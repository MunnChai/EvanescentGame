class_name PossessableNPC
extends NPC

var is_possessed: bool = false

func _physics_process(delta):
	if (is_possessed):
		if (player.is_input_active):
			handle_input(delta)
		
		handle_player_movement(delta)
	else:
		handle_npc_movement(delta)
	
	handle_animation()

func become_possessed():
	is_possessed = true
	interactable_area.disable()
	inventory.visible = true
	clear_navigation_agent_connections()
	update_current_location()

func become_unpossessed():
	is_possessed = false
	interactable_area.enable()
	inventory.visible = false
	update_current_location()

func on_player_interacted():
	dialogue_emitter.show_dialogue(current_dialogue_title)

func show_possession_effect():
	pass

func hide_possession_effect():
	pass
