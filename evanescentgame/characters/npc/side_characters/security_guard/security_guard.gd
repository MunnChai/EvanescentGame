class_name SecurityGuardNPC
extends NPC

@onready var security_guard_dialogue_trigger: SecurityGuardDialogueTrigger = $SecurityGuardDialogueTrigger

@export var trigger_dialogue: DialogueResource
@export var trigger_default_title: String
@export var push_direction: float = 1

func _ready():
	super._ready()
	
	security_guard_dialogue_trigger.set_dialogue_resource(trigger_dialogue)
	security_guard_dialogue_trigger.set_dialogue_heading(trigger_default_title)
	security_guard_dialogue_trigger.set_push_direction(push_direction)
	
	EventHandler.security_guard_text_sent.connect(leave_post)

func _physics_process(delta):
	handle_npc_movement(delta)
	handle_animation()

func disable_guard_trigger():
	security_guard_dialogue_trigger.disable_trigger()

func enable_guard_trigger():
	security_guard_dialogue_trigger.enable_trigger()

func leave_post():
	disable_guard_trigger()
	navigate_to(UNREACHABLE_LOCATION_COORDS)

