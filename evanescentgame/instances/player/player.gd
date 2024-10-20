class_name Player
extends CharacterBody2D

## CONSTANTS
const SPEED: float = 175.0
const ACCEL_DECAY_CONST: float = 6.0 # How fast should smoothing be

@onready var sprite_2d = $Sprite2D

var is_possessing: bool = false
var currently_possessed_npc: NPC = null

var is_input_active: bool = true

func _ready():
	DialogueManager.dialogue_ended.connect(
		func(dialogue_resource: Resource):
			is_input_active = true
	)

func _physics_process(delta: float):
	if (not is_input_active):
		return
	
	handle_input(delta)
	if (not is_possessing):
		handle_movement(delta)
	else:
		global_position = currently_possessed_npc.global_position

func handle_input(delta: float):
	if (Input.is_action_just_pressed("exit_possessee") and is_possessing):
		stop_possessing()

func handle_movement(delta: float):
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	
	# velocity = velocity.move_toward(Vector2(direction_x, direction_y).normalized() * SPEED, SPEED)
	velocity = Vector2(MathUtil.decay(velocity, Vector2(direction_x, direction_y).normalized() * SPEED, ACCEL_DECAY_CONST, delta))
	
	move_and_slide()

func possess(npc: NPC):
	sprite_2d.visible = false
	is_possessing = true
	currently_possessed_npc = npc
	npc.become_possessed()

func stop_possessing():
	global_position = currently_possessed_npc.global_position + Vector2(0, 3)
	currently_possessed_npc.become_unpossessed()
	currently_possessed_npc = null
	is_possessing = false
	sprite_2d.visible = true
