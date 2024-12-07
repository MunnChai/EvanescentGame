extends Node2D

@export var dialogue_resource: DialogueResource
@export var dialogue_title: String

@onready var interactable_area = $InteractableArea
@onready var dialogue_emitter = $DialogueEmitter

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_emitter.dialogue_resource = dialogue_resource
	interactable_area.player_interacted.connect(show_dialogue)
	print(dialogue_resource.get_titles())

func show_dialogue():
	dialogue_emitter.show_dialogue(dialogue_title)
	
	if (dialogue_resource.titles.has(dialogue_title + "_repeat")):
		dialogue_title = dialogue_title + "_repeat"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
