class_name Item
extends Node2D

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var interactable_area = $InteractableArea
@onready var sprite_2d = $Sprite2D
@onready var dialogue_emitter = $DialogueEmitter

signal signal_dialogue(title: String)

func on_player_interacted():
	if (player.is_possessing):
		show_human_dialogue()
	else:
		show_ghost_dialogue()

func show_human_dialogue():
	signal_dialogue.emit("test_item_human")

func show_ghost_dialogue():
	signal_dialogue.emit("test_item_ghost")
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)

func on_dialogue_ended(dialogue_resource: Resource):
	if (dialogue_resource == dialogue_emitter.dialogue_resource and player.is_possessing):
		pick_up()

func pick_up():
	interactable_area.disable()
	player.currently_possessed_npc.add_to_inventory(self)
	sprite_2d.visible = false
