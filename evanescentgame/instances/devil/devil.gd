class_name Devil
extends CharacterBody2D

## Interaction behaviour for Lady Devil
## Mainly dialogue

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var interactable_area: InteractableArea = $InteractableArea

signal signal_dialogue(title: String)

func _ready():
	pass

func _physics_process(delta):
	pass

func on_player_interacted():
	signal_dialogue.emit("talking_to_devil")
