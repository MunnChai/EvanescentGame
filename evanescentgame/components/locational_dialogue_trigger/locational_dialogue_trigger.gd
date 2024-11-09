class_name LocationalDialogueTrigger
extends Area2D

## LOCATIONAL DIALOGUE TRIGGER
## Runs the dialogue "cutscene" sequence the first time the player touches the area

## File containing the dialogue sequence.
@export var dialogue_resource: Resource = null
## The name of the dialogue sequence to run. Defaults to one_time. 
@export var dialogue_heading: String = "one_time"

# References
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var dialogue_emitter = $DialogueEmitter

var already_triggered := false



func _ready() -> void:
	# Assign dialogue resource to the DialogueEmitter
	dialogue_emitter.dialogue_resource = dialogue_resource

func _on_body_entered(body) -> void:
	if body is Player:
		_call_dialogue()

func _call_dialogue() -> void:
	if already_triggered: # Don't call if it's already triggered
		return
	already_triggered = true
	
	dialogue_emitter.show_dialogue(dialogue_heading)


