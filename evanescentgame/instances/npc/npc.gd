class_name NPC
extends CharacterBody2D

@onready var ground_ray_cast: RayCast2D = $GroundRayCast
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var navigation_agent_2d = $NavigationAgent2D

const SPEED: float = 125.0
const SPRINT_MULTIPLIER: float = 1.5
const JUMP_VELOCITY: float = 250
const GRAVITY: float = 1000

signal signal_dialogue(title: String)

var is_possessed: bool = false
var currently_held_item: Item = null

func _physics_process(delta):
	if (is_possessed):
		handle_player_movement(delta)
		handle_input(delta)
	else:
		handle_npc_movement(delta)

func on_player_interacted():
	if (player.is_possessing):
		signal_dialogue.emit("test_npc_convo")
	else:
		player.possess(self)

func become_possessed():
	phantom_camera_2d.priority = 20
	is_possessed = true
	interactable_area.disable()

func become_unpossessed():
	is_possessed = false
	phantom_camera_2d.priority = 0
	interactable_area.enable()

func add_to_inventory(item: Item):
	currently_held_item = item

func handle_input(delta: float):
	if (Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y -= JUMP_VELOCITY

func handle_player_movement(delta: float):
	if (not is_on_floor()):
		velocity.y += GRAVITY * delta
		
		if (ground_ray_cast.is_colliding()):
			position.y += 1
	
	var true_speed = SPEED
	if (Input.is_action_pressed("sprint")):
		true_speed *= SPRINT_MULTIPLIER
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * true_speed, true_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, true_speed)
	
	move_and_slide()

func handle_npc_movement(delta: float):
	if (not navigation_agent_2d.is_navigation_finished()):
		var direction: float = sign(navigation_agent_2d.get_next_path_position().x - global_position.x)
		
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED)
		
		move_and_slide()

func navigate_to(target_position: Vector2, location):
	# If location != current_location, navigate to location_exit
	
	# navigate to location
	navigation_agent_2d.target_position = target_position
	print("Navigating to: ", target_position)
