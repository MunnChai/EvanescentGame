extends Node2D

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@export var dialogue_resource: Resource

func show_dialogue(title: String):
	player.is_input_active = false
	DialogueManager.show_dialogue_balloon(dialogue_resource, title)
 
