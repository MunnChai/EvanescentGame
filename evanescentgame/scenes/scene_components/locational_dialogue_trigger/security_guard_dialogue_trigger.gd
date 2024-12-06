class_name SecurityGuardDialogueTrigger
extends Area2D

const PUSH_FORCE: float = 100

## Runs the dialogue "cutscene" sequence the first time the player touches the area

## File containing the dialogue sequence.
@export var dialogue_resource: Resource = null
## The name of the dialogue sequence to run. Defaults to one_time. 
@export var dialogue_heading: String = "one_time"

# References
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var dialogue_emitter = $DialogueEmitter

var already_triggered := false
var is_enabled := true

var push_direction: float = 1 # positive is to the right, negative is to the left

func _ready() -> void:
	# Assign dialogue resource to the DialogueEmitter
	dialogue_emitter.dialogue_resource = dialogue_resource

func _on_body_entered(body) -> void:
	if (not is_enabled):
		return
	
	if (body is Player):
		if (body.is_possessing):
			_call_dialogue(body)

func _call_dialogue(player: Player) -> void:
	if (player.currently_possessed_npc.name == "Kai"):
		dialogue_emitter.show_dialogue("colleague_entered") # SOME OTHER DIALOGUE
	else:
		dialogue_emitter.show_dialogue(dialogue_heading)
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended.bind(player))

func enable_trigger():
	is_enabled = true

func disable_trigger():
	is_enabled = false

func _on_dialogue_ended(dialogue_resource: DialogueResource, player: Player): # push the player back in a direction
	player.currently_possessed_npc.velocity.x = push_direction * PUSH_FORCE
	
	if (DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended)):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

func set_dialogue_resource(dialogue_resource: DialogueResource):
	self.dialogue_resource = dialogue_resource
	dialogue_emitter.dialogue_resource = dialogue_resource

func set_dialogue_heading(heading: String):
	dialogue_heading = heading

func set_push_direction(direction: float):
	push_direction = sign(direction)
