extends NPC

@onready var animation_player = $AnimationPlayer

func _physics_process(delta):
	if (is_possessed and player.is_input_active):
		handle_player_movement(delta)
		handle_input(delta)
		inventory.visible = true
		play_footsteps();
	else:
		handle_npc_movement(delta)
		inventory.visible = false

func play_footsteps():
	if (is_on_floor() and velocity.x != 0):
		animation_player.play("waddle");
	else:
		animation_player.play("RESET");
