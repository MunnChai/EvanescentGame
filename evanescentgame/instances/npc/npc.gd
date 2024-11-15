class_name NPC
extends CharacterBody2D

@onready var ground_ray_cast: RayCast2D = $GroundRayCast
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var inventory = $CanvasLayer/Inventory

@export var starting_location: Location

const SPEED: float = 125.0
const SPRINT_MULTIPLIER: float = 1.5
const JUMP_VELOCITY: float = 250
const GRAVITY: float = 1000

signal signal_dialogue(title: String)

var is_possessed: bool = false
var current_location: Location

func _ready():
	current_location = starting_location

func _physics_process(delta):
	if (is_possessed):
		handle_player_movement(delta)
		handle_input(delta)
		inventory.visible = true
	else:
		handle_npc_movement(delta)
		inventory.visible = false

func on_player_interacted():
	if (player.is_possessing):
		signal_dialogue.emit("test_npc_convo")
	else:
		player.possess(self)

func become_possessed():
	is_possessed = true
	interactable_area.disable()

func become_unpossessed():
	is_possessed = false
	interactable_area.enable()

func add_to_inventory(item: Item):
	if (inventory.items.size() < 3):
		inventory.items.append(item)
		inventory.update_slots()

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
	# Apply gravity
	if (not is_on_floor()):
		velocity.y += GRAVITY * delta
	
	if (not navigation_agent_2d.is_navigation_finished()):
		const NEAR_DISTANCE: float = 10 # Near distance threshold to next node
		
		# Get next node in the path to the target position, and the direction from the NPC to that node
		var current_node = navigation_agent_2d.get_next_path_position()
		var x_distance: float = current_node.x - global_position.x
		var x_direction: float = sign(x_distance)
		
		# Move towards the next node
		velocity.x = move_toward(velocity.x, x_direction * SPEED, SPEED / 4)
		
		# Get NEXT next node and check if it is valid
		var path = navigation_agent_2d.get_current_navigation_path()
		var next_index = navigation_agent_2d.get_current_navigation_path_index() + 1
		if (next_index < path.size()):
			var next_node = path[next_index]
		
			var next_node_angle: float = (current_node - next_node).normalized().angle()
			var next_node_degrees: float = rad_to_deg(next_node_angle)
			
			# If NPC is at the next node, calculate the angle to the NEXT next node to see if a jump is necessary
			if (abs(x_distance) < NEAR_DISTANCE and 
				next_node_degrees > 40 and 
				next_node_degrees < 140 and 
				is_on_floor()):
				
				# Jump
				velocity.y -= JUMP_VELOCITY
		
		if (velocity.y < 0): # Stay still while jumping, just helps to not stray too far off the path
			velocity.x = move_toward(velocity.x, 0, SPEED / 4)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 4)
	
	
	move_and_slide()

func navigate_to(target_position: Vector2, location: Location):
	# If location != current_location, navigate to location_exit
	if (current_location != location):
		navigation_agent_2d.target_position = current_location.location_exit.global_position
		navigation_agent_2d.navigation_finished.connect(travel_to.bind(location, target_position))
		print("Not at target location! Navigating to location exit...")
		return
	
	# navigate to location
	navigation_agent_2d.target_position = target_position
	print("Navigating to: ", target_position)

func travel_to(location: Location, target_position: Vector2):
	global_position = location.location_exit.global_position
	current_location = location
	
	navigate_to(target_position, location)
	
	if (navigation_agent_2d.navigation_finished.is_connected(travel_to)):
		navigation_agent_2d.navigation_finished.disconnect(travel_to)



