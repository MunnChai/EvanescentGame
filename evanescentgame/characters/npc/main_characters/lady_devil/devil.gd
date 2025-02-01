class_name Devil
extends NPC

## Interaction behaviour for Lady Devil
## Mainly dialogue

@export var dialogue_key: String = "talking_to_devil"

@onready var devil_animator = $DevilAnimator

func on_player_interacted():
	dialogue_emitter.show_dialogue(dialogue_key)

func _physics_process(delta):
	handle_animation()

func handle_animation():
	devil_animator.play("lady_devil_podium_idle")
