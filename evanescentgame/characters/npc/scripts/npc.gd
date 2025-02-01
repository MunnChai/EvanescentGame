class_name NPC
extends CharacterBody2D

@onready var ground_ray_cast: RayCast2D = $GroundRayCast
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var dialogue_emitter: DialogueEmitter = $DialogueEmitter
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var inventory: Inventory = $CanvasLayer/Inventory
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var graph_data: DecisionTreeGraphData
@export var starting_dialogue_resource: DialogueResource
@export var current_dialogue_title: String

const SPEED: float = 40.0
const SPRINT_MULTIPLIER: float = 1.75
const JUMP_VELOCITY: float = 250
const GRAVITY: float = 1000
const OUTLINE_COLOUR: Color = Color(0.2, 0.2, 0.2)

const UNREACHABLE_LOCATION_COORDS: Vector2 = Vector2(2000, 2000)

const MOVE_ROOMS_WAIT_TIME: float = 0.5
const NPC_PIVOT_OFFSET = Vector2(0, 30)

var is_navigating: bool = false
var end_target_position: Vector2
var starting_location: Location
var starting_room: LocationRoom

var current_location: Location
var prev_location: Location
var current_room: LocationRoom
var current_room_path: Array

signal signal_dialogue(title) # REMOVE AT SOME POINT, PLS DON'T USE THIS, INSTEAD CALL dialogue_emitter.show_dialogue(title)
signal location_updated
signal completed_navigation

func _ready():
	if (sprite_2d.material):
		sprite_2d.material.set_shader_parameter("number_of_images", Vector2(sprite_2d.hframes, sprite_2d.vframes))
		sprite_2d.material.set_shader_parameter("color", OUTLINE_COLOUR)
	
	dialogue_emitter.dialogue_resource = starting_dialogue_resource
	if (!interactable_area.player_interacted.is_connected(on_player_interacted)): 
		interactable_area.player_interacted.connect(on_player_interacted)
	
	update_current_location()
	
	inventory.visible = false
	for slot in inventory.slots:
		slot.connect("drop_item", drop_from_inventory)

func _physics_process(delta):
	handle_npc_movement(delta)
	handle_animation()

func on_player_interacted():
	dialogue_emitter.show_dialogue(current_dialogue_title)


# Dialogue Things
func set_dialogue_resource(path: String, title: String = ""):
	var dialogue_resource = load(path)
	
	dialogue_emitter.dialogue_resource = dialogue_resource
	
	if (title != ""):
		current_dialogue_title = title

func set_dialogue_title(title: String):
	current_dialogue_title = title

func disable_interactable():
	interactable_area.disable()

func enable_interactable():
	interactable_area.enable()





func inventory_contains_item_id(item_id: String) -> bool:
	for item in inventory.items:
		if (item.item_id == item_id):
			return true
	
	return false

func add_to_inventory(item: Item):
	if (inventory.items.size() < 3):
		inventory.items.append(item)
		inventory.update_slots()

func remove_from_inventory(item: Item):
	if (inventory.items.has(item)):
		inventory.items.erase(item)
		inventory.update_slots()

# not sure if the function above is intended for dropping items
func drop_from_inventory(item: Item):
	if (inventory.items.has(item)):
		inventory.items.erase(item)
		inventory.update_slots()
		
		item.interactable_area.enable()
		item.visible = true
		item.position = self.position + Vector2(0, -8)

func remove_from_inventory_id(item_id: String):
	for item in inventory.items:
		if (item.item_id == item_id):
			inventory.items.erase(item)
			inventory.update_slots()
			return

func handle_animation():
	if (velocity.length() > SPEED):
		animation_player.play("run")
	elif (velocity.length() > 0):
		animation_player.play("walk")
	else:
		var rand = randf_range(0.5, 1.5)
		animation_player.play("idle", -1, rand)
	
	if (velocity.x > 0):
		sprite_2d.flip_h = false
	elif (velocity.x < 0):
		sprite_2d.flip_h = true




func update_current_location():
	var location_managers = get_tree().get_nodes_in_group("location_manager")
	
	if (location_managers.size() == 0):
		return
	
	var location_manager = location_managers[0]
	
	for location: Location in location_manager.get_children():
		if (location.area_contains_position(global_position)):
			prev_location = current_location
			current_location = location
			location_updated.emit()
			break
	
	if (!current_location):
		print("The NPC: ", name, ", is not in any location's area!")
		return
	
	current_room = current_location.get_room_of_position(global_position)
	
	if (!current_room):
		print("The NPC: ", name, ", is not in any of location's rooms!")
		return

func handle_npc_movement(delta: float):
	var clock = get_tree().get_first_node_in_group("clock")
	if (clock.clock.timer.paused): # Munn: this line makes me want to HURL lol
		velocity = Vector2(0, 0)
		return
	
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
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 4)
		
	move_and_slide()

func jump():
	velocity.y -= JUMP_VELOCITY







# Call this to navigate your NPC to the desired position (position must be within a LocationRoom's area)
func navigate_to(target_position: Vector2, dialogue_resource_path: String = "", dialogue_title: String = ""):
	is_navigating = true
	end_target_position = target_position
	
	if (dialogue_resource_path != ""):
		completed_navigation.connect(
			func():
				for connection in completed_navigation.get_connections():
					completed_navigation.disconnect(connection["callable"])
				
				set_dialogue_resource(dialogue_resource_path)
				set_dialogue_title(dialogue_title)
		)
	move_to(target_position)

func move_to(target_position: Vector2):
	update_current_location()
	clear_navigation_agent_connections()
	var location_manager = get_tree().get_nodes_in_group("location_manager")[0]
	var unreachable_locations = get_tree().get_nodes_in_group("unreachable_locations")
	var locations = location_manager.get_children()
	locations.append_array(unreachable_locations)
	
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
			navigation_agent_2d.navigation_finished.connect(
				func():
					is_navigating = false
					completed_navigation.emit()
			)
			return




func enter_door(door: BackgroundDoor, target_position: Vector2):
	await get_tree().create_timer(MOVE_ROOMS_WAIT_TIME).timeout
	
	global_position = door.destination_door.global_position
	sprite_2d.visible = false
	move_to_ground()
	
	current_room = current_location.get_room_of_position(global_position)
	
	await get_tree().create_timer(MOVE_ROOMS_WAIT_TIME).timeout
	
	move_to(target_position)

func move_to_location(location: Location, target_position: Vector2):
	await get_tree().create_timer(MOVE_ROOMS_WAIT_TIME).timeout
	
	# Collision calculation lag prevention stuff??
	collision_mask = 0
	sprite_2d.visible = false
	global_position = location.location_exit.global_position
	prev_location = current_location
	current_location = location
	location_updated.emit()
	current_room = location.location_exit_room
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	collision_mask = 1
	move_to_ground()
	
	await get_tree().create_timer(MOVE_ROOMS_WAIT_TIME).timeout
	
	move_to(target_position)

func clear_navigation_agent_connections():
	for connection in navigation_agent_2d.navigation_finished.get_connections():
		navigation_agent_2d.navigation_finished.disconnect(connection["callable"])

func move_to_ground():
	sprite_2d.visible = false # prevent 1 frame of floating
	
	var raycast = RayCast2D.new()
	raycast.target_position = Vector2(0, 100)
	
	add_child(raycast)
	
	await get_tree().physics_frame
	
	if (raycast.is_colliding()):
		global_position = raycast.get_collision_point()
	
	remove_child(raycast)
	
	sprite_2d.visible = true
