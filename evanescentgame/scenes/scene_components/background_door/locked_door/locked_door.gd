extends BackgroundDoor


@export var key_id: String
@export var is_locked: bool = true

@export_category("DialogueThings")
@export var dialogue_resource: DialogueResource
@export var dialogue_title: String

@onready var dialogue_emitter: DialogueEmitter = $DialogueEmitter


# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_emitter.dialogue_resource = dialogue_resource
	interactable_area.player_interacted.connect(_on_player_interacted)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## When the player interacts with the door...
func _on_player_interacted() -> void:
	if (is_locked):
		_interact_locked()
	else:
		_enter_process()

func unlock():
	is_locked = false

func _interact_locked():
	if (!player.currently_possessed_npc):
		dialogue_emitter.show_dialogue(dialogue_title + "_locked")
		return
	
	if player.currently_possessed_npc.inventory_contains_item_id(key_id):
		unlock()
		player.currently_possessed_npc.remove_from_inventory_id(key_id)
		dialogue_emitter.show_dialogue(dialogue_title + "_unlocked")
	else:
		dialogue_emitter.show_dialogue(dialogue_title + "_locked")
