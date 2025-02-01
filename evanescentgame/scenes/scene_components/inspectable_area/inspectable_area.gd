extends Node2D

@export var dialogue_resource: DialogueResource
@export var dialogue_title: String
@export var requires_human: bool = false

@onready var interactable_area = $InteractableArea
@onready var dialogue_emitter = $DialogueEmitter

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_emitter.dialogue_resource = dialogue_resource
	interactable_area.player_interacted.connect(show_dialogue)
	print(dialogue_resource.get_titles())

func show_dialogue():
	if (requires_human):
		show_specific_dialogue()
		return
	
	dialogue_emitter.show_dialogue(dialogue_title)
	
	if (dialogue_resource.titles.has(dialogue_title + "_repeat")):
		dialogue_title = dialogue_title + "_repeat"

func show_specific_dialogue():
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if (player.is_possessing):
		dialogue_emitter.show_dialogue(dialogue_title + "_human")
	else:
		dialogue_emitter.show_dialogue(dialogue_title + "_ghost")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
