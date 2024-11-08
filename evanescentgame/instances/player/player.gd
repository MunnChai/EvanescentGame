class_name Player
extends CharacterBody2D

## CONSTANTS
const SPEED: float = 100.0
const ACCEL_DECAY_CONST: float = 6.0 # How fast should smoothing be

@onready var sprite_2d = $Sprite2D


var is_possessing: bool = false
var currently_possessed_npc: NPC = null

var is_input_active: bool = true

@onready var starting_sprite_position : Vector2 = $Sprite2D.position

func _ready():
	DialogueManager.dialogue_ended.connect(
		func(dialogue_resource: Resource):
			is_input_active = true
	)
	
	$EvanSuckAnimation.hide()

## TEMP
## VERY TEMP CODE 
## REFACTOR AS SOON AS POSSIBLE
static var is_the_end := false # true if it is the end
var has_ended := false # true if it has ended

@onready var evan_suck_animation_origin : Vector2 = $EvanSuckAnimation.position

func the_end() -> void:
	if has_ended:
		return
	has_ended = true
	
	$EvanSuckAnimation.show()
	$EvanSuckAnimation.play()
	$Sprite2D.hide()
	
	is_input_active = false



var accumulated_time := 0.0
func _process(delta):
	#if Input.is_key_label_pressed(KEY_R):
		#is_the_end = true
	
	if is_the_end:
		the_end()
	
	accumulated_time += delta
	$Sprite2D.position = starting_sprite_position + Vector2.UP * 3.0 * sin(accumulated_time) + Vector2.UP * 3.0
	
	if not is_the_end:
		$EvanSuckAnimation.position = evan_suck_animation_origin + Vector2.UP * 3.0 * sin(accumulated_time) + Vector2.UP * 3.0

func _physics_process(delta: float):
	handle_input(delta)
	if (not is_possessing):
		handle_movement(delta)
	else:
		global_position = currently_possessed_npc.global_position

func handle_input(delta: float):
	if (Input.is_action_just_pressed("exit_possessee") and is_possessing):
		stop_possessing()

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
