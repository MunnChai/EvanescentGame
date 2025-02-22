extends Area2D

const PUSH_FORCE: float = 100

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var dialogue_emitter = $DialogueEmitter

var already_triggered := false
var is_enabled := true

var push_direction = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if (not is_enabled):
		return
	
	if (body is Player):
		if (body.is_possessing && body.currently_possessed_npc.name == "Kai"):
			if (body.currently_possessed_npc.inventory_contains_item_id("organization_badge")):
				is_enabled = false
			else:
				DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
			
			dialogue_emitter.show_dialogue("Kai_Organization_ID_Trigger")

func _on_dialogue_ended(dialogue_resource: DialogueResource): # push the player back in a direction
	player.currently_possessed_npc.velocity.x = push_direction * PUSH_FORCE
	
	if (DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended)):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
