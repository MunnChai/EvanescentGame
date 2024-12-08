class_name DialogueEmitter
extends Node2D

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@export var dialogue_resource: Resource
@export var default_title = ""

func show_dialogue(title: String = ""):
	if (title == ""):
		DialogueManager.show_dialogue_balloon(dialogue_resource, default_title)
	else:
		DialogueManager.show_dialogue_balloon(dialogue_resource, title)
	
	player.is_input_active = false
