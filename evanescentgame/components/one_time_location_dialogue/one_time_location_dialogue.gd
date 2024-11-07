class_name OneTimeLocationDialogue
extends Area2D

## One Time Location Dialogue
## Calls dialogue one time when the player enters the area...

@export var dialogue_resource: Resource
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

var already_triggered := false

func _ready():
	$DialogueEmitter.dialogue_resource = dialogue_resource

func _player_procedure() -> void:
	if already_triggered:
		return
	already_triggered = true
	
	$DialogueEmitter.show_dialogue("one_time")



func _on_body_entered(body):
	if (body is Player):
		_player_procedure()
