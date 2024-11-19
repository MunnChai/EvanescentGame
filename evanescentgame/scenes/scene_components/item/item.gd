class_name Item
extends Node2D

@export var item_id: String = ""

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var interactable_area = $InteractableArea
@onready var dialogue_emitter = $DialogueEmitter
@onready var sprite_2d = $Sprite2D

signal signal_dialogue(title: String)

func on_player_interacted():
	if (player.is_possessing):
		show_human_dialogue()
	else:
		show_ghost_dialogue()

func show_human_dialogue():
	signal_dialogue.emit("test_item_human")
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)

func show_ghost_dialogue():
	signal_dialogue.emit("test_item_ghost")

func on_dialogue_ended(dialogue_resource: Resource):
	pick_up()
	DialogueManager.dialogue_ended.disconnect(on_dialogue_ended)

func pick_up():
	interactable_area.disable()
	player.currently_possessed_npc.add_to_inventory(self)
	self.visible = false
