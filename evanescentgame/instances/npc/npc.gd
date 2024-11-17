class_name NPC
extends CharacterBody2D

@onready var ground_ray_cast: RayCast2D = $GroundRayCast
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var dialogue_emitter = $DialogueEmitter
@onready var sprite_2d = $Sprite2D
@onready var inventory = $CanvasLayer/Inventory

@export var graph_data: DecisionTreeGraphData
@export var starting_dialogue_resource: DialogueResource
@export var current_dialogue_title: String

const SPEED: float = 40.0
const SPRINT_MULTIPLIER: float = 1.5
const JUMP_VELOCITY: float = 250
const GRAVITY: float = 1000

var starting_location: Location
var starting_room: LocationRoom

var is_possessed: bool = false
var current_location: Location
var current_room: LocationRoom
var current_room_path: Array

func _ready():
	dialogue_emitter.dialogue_resource = starting_dialogue_resource
	
	var location_managers = get_tree().get_nodes_in_group("location_manager")
	
	if (location_managers.size() == 0):
		return
	
	var location_manager = location_managers[0]
	
	for location: Location in location_manager.get_children():
		if (location.area_contains_position(global_position)):
			current_location = location
			break
	
	if (!current_location):
		print("The NPC: ", name, ", is not in any location's area!")
		return
	
	current_room = current_location.get_room_of_position(global_position)
	
	if (!current_room):
		print("The NPC: ", name, ", is not in any of location's rooms!")
		return

func _physics_process(delta):
	if (is_possessed):
		handle_player_movement(delta)
		handle_input(delta)
		inventory.visible = true
	else:
		handle_npc_movement(delta)
		inventory.visible = false

func on_player_interacted():
	#if (player.is_possessing):
		#signal_dialogue.emit("test_npc_convo")
	#else:
		#player.possess(self)
	
	dialogue_emitter.show_dialogue(current_dialogue_title)


# Dialogue Things
func set_dialogue_resource(path: String):
	var dialogue_resource = load(path)
	
	dialogue_emitter.dialogue_resource = dialogue_resource

func set_dialogue_title(title: String):
	current_dialogue_title = title




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
		jump()








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
				jump()
		
		if (velocity.y < 0): # Stay still while jumping, just helps to not stray too far off the path
			velocity.x = move_toward(velocity.x, 0, SPEED / 4)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 4)
	
	sprite_2d.flip_h = -sign(velocity.x)
	move_and_slide()

func jump():
	velocity.y -= JUMP_VELOCITY







# Call this to navigate your NPC to the desired position (position must be within a LocationRoom's area)
func navigate_to(target_position: Vector2):
	var location_manager = get_tree().get_nodes_in_group("location_manager")[0]
	var locations = location_manager.get_children()
	
	# Get target location
	var target_location: Location
	for location: Location in locations:
		if (location.area_contains_position(target_position)):
			target_location = location
			break
	
	# Null check
	if (!target_location):
		print("Target position, ", target_position, ", is not in any location's area!")
		return
	
	# IF STATEMENT HELL DDDDD:
	if (current_location != target_location): # If target_location != current_location, navigate to location_exit_room
		if (current_room != current_location.location_exit_room): # If current_room != location_exit_room, navigate to location_exit_room
			if (current_room_path.size() == 0):
				current_room_path = current_location.find_path_between(current_room, current_location.location_exit_room)
			
			var next_door: BackgroundDoor = current_room_path.pop_front()
			navigation_agent_2d.target_position = next_door.global_position
			navigation_agent_2d.navigation_finished.connect(enter_door.bind(next_door, target_position))
			return
		else: # If current_room == location_exit_room, navigate to location_exit and teleport to target_location
			navigation_agent_2d.target_position = current_location.location_exit.global_position
			navigation_agent_2d.navigation_finished.connect(move_to_location.bind(target_location, target_position))
			return
	else: # If target_location == current_location, navigate to target_room
		# Get target room
		var target_room: LocationRoom = target_location.get_room_of_position(target_position)
		
		if (!target_room):
			print("Target position, ", target_position, ", is in ", target_location.name, ", but is not in any of the rooms' areas!")
			return
		
		if (current_room != target_room): # If current_room != target_room, navigate to target_room
			if (current_room_path.size() == 0):
				current_room_path = current_location.find_path_between(current_room, target_room)
			
			var next_door: BackgroundDoor = current_room_path.pop_front()
			navigation_agent_2d.target_position = next_door.global_position
			navigation_agent_2d.navigation_finished.connect(enter_door.bind(next_door, target_position))
			return
		else: # If current_room == target_room, navigate to target_position
			navigation_agent_2d.target_position = target_position
			return

func enter_door(door: BackgroundDoor, target_position: Vector2):
	global_position = door.destination_door.global_position
	current_room = current_location.get_room_of_position(global_position)
	
	navigate_to(target_position)
	
	if (navigation_agent_2d.navigation_finished.is_connected(enter_door)):
		navigation_agent_2d.navigation_finished.disconnect(enter_door)

func move_to_location(location: Location, target_position: Vector2):
	global_position = location.location_exit.global_position
	current_location = location
	current_room = location.location_exit_room
	
	navigate_to(target_position)
	
	if (navigation_agent_2d.navigation_finished.is_connected(move_to_location)):
		navigation_agent_2d.navigation_finished.disconnect(move_to_location)



