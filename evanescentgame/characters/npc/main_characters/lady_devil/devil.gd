class_name Devil
extends NPC

## Interaction behaviour for Lady Devil
## Mainly dialogue

@onready var devil_animator = $DevilAnimator

func on_player_interacted():
	dialogue_emitter.show_dialogue("talking_to_devil")

func _physics_process(delta):
	handle_animation()

func handle_animation():
	devil_animator.play("lady_devil_podium_idle")
