extends Node2D

@export var dialogue_resource: DialogueResource
@export var dialogue_title: String

@onready var interactable_area = $InteractableArea
@onready var dialogue_emitter = $DialogueEmitter

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_emitter.dialogue_resource = dialogue_resource
	interactable_area.player_interacted.connect(dialogue_emitter.show_dialogue.bind(dialogue_title))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
