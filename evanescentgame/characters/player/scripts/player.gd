class_name Player
extends CharacterBody2D

## CONSTANTS
const SPEED: float = 100.0
const ACCEL_DECAY_CONST: float = 6.0 # How fast should smoothing be
const EXIT_POSSESSION_SPEED: float = 200
const NPC_CENTER_OFFSET: Vector2 = Vector2(0, -30)

@onready var sprite_2d = $Sprite2D
#@onready var ingame_ui = $CanvasLayer/Ingame

var in_possessing_animation: bool = false
var is_possessing: bool = false
var currently_possessed_npc: NPC = null

var is_input_active: bool = true

# THIS NEEDS TO BE REFACTORED!
static var knows_name: bool = false;
static var knows_devil_name: bool = false;
static var num_branches_chosen = 0;

var current_interactables: Array[InteractableArea]
var closest_interactable: InteractableArea

@onready var starting_sprite_position : Vector2 = $Sprite2D.position

func _ready():
	DialogueManager.dialogue_ended.connect(
		func(dialogue_resource: Resource):
			is_input_active = true
	)

func show_sprite() -> void:
	sprite_2d.show()
func hide_sprite() -> void:
	sprite_2d.hide()



var accumulated_time := 0.0
func _process(delta):
	accumulated_time += delta
	sprite_2d.position = starting_sprite_position + Vector2.UP * 3.0 * sin(accumulated_time) + Vector2.UP * 3.0

func _physics_process(delta: float):
	handle_input(delta)
	if (not is_possessing and not in_possessing_animation):
		handle_movement(delta)
	elif (is_possessing and not in_possessing_animation):
		global_position = currently_possessed_npc.global_position + NPC_CENTER_OFFSET
	
	if (velocity.length() > 0 or (is_possessing and currently_possessed_npc.velocity.length() > 0)):
		update_closest_interactable()

func handle_input(delta: float):
	if (Input.is_action_just_pressed("exit_possessee") and is_possessing):
		stop_possessing()
	
	if (Input.is_action_just_pressed("interact") and is_input_active):
		interact_with_closest_interactable()

func handle_movement(delta: float):
	var direction_x = 0
	var direction_y = 0
	if (is_input_active):
		direction_x = Input.get_axis("move_left", "move_right")
		direction_y = Input.get_axis("move_up", "move_down")
	
	# velocity = velocity.move_toward(Vector2(direction_x, direction_y).normalized() * SPEED, SPEED)
	velocity = Vector2(MathUtil.decay(velocity, Vector2(direction_x, direction_y).normalized() * SPEED, ACCEL_DECAY_CONST, delta))
	
	if velocity.x > 0:
		($Sprite2D as Sprite2D).flip_h = false
	elif velocity.x < 0:
		($Sprite2D as Sprite2D).flip_h = true
	
	move_and_slide()

func possess(npc: NPC):
	in_possessing_animation = true
	
	const DISTANCE_THRESHOLD: float = 5
	const MIN_SPEED: float = 50
	var direction: Vector2 = (npc.global_position + NPC_CENTER_OFFSET) - global_position
	var distance_to_npc: float = direction.length() 
	
	while (distance_to_npc > DISTANCE_THRESHOLD):
		velocity = direction.normalized() * max(pow(distance_to_npc, 1.5), MIN_SPEED)
		
		direction = (npc.global_position + NPC_CENTER_OFFSET) - global_position
		distance_to_npc = direction.length()
		move_and_slide()
		await get_tree().physics_frame
	 
	sprite_2d.visible = false
	#ingame_ui.get_node("Fade").visible = false
	#ingame_ui.get_node("Vignette").visible = true
	is_possessing = true
	currently_possessed_npc = npc
	npc.become_possessed()
	in_possessing_animation = false

func stop_possessing():
	global_position = currently_possessed_npc.global_position + NPC_CENTER_OFFSET
	velocity = Vector2(0, -EXIT_POSSESSION_SPEED)
	currently_possessed_npc.become_unpossessed()
	currently_possessed_npc = null
	is_possessing = false
	sprite_2d.visible = true
	#ingame_ui.get_node("Fade").visible = true
	#ingame_ui.get_node("Vignette").visible = false
	
static func increment_branches():
	num_branches_chosen += 1




func update_closest_interactable():
	if (current_interactables.size() == 0): 
		return
	
	var current_closest_distance: float = INF
	if (closest_interactable):
		closest_interactable.hide_interact_symbol()
	
	for interactable in current_interactables:
		if (!closest_interactable):
			closest_interactable = interactable
			current_closest_distance = (global_position - interactable.global_position).length()
		else:
			var distance = (global_position - interactable.global_position).length()
			if (distance < current_closest_distance):
				closest_interactable = interactable
				current_closest_distance = distance
	
	closest_interactable.show_interact_symbol()

func interact_with_closest_interactable():
	closest_interactable.interact()

func add_interactable(interactable: InteractableArea):
	current_interactables.append(interactable)

func remove_interactable(interactable: InteractableArea):
	current_interactables.erase(interactable)