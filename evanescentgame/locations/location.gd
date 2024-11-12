class_name Location
extends Node2D

@onready var location_exit: LocationExit = $LocationExit
@onready var location_area: CollisionShape2D = $LocationArea
@onready var rooms_node: Node2D = $Rooms
var rooms: Array
var location_exit_room: LocationRoom

@export var room1: LocationRoom
@export var room2: LocationRoom

# Called when the node enters the scene tree for the first time.
func _ready():
	if (!rooms_node):
		return
	
	rooms = rooms_node.get_children()
	
	location_exit_room = get_room_of_position(location_exit.global_position)
	
	if (!location_exit_room):
		print("Location Exit Room not found in location: ", name)
	
	print(find_path_between(room1, room2))

# Breadth First Search YAY DATA STRUCTURES AND ALGORITHMSSS
func find_path_between(start_room: LocationRoom, end_room: LocationRoom):
	if (!start_room or !end_room):
		return
	
	# Initialize BFS
	var rooms_to_traverse: Array[LocationRoom] = [start_room]
	var paths: Array[Array] = [[]] # an Array[Array[BackgroundDoor]], but nested collections are not supported in Godot
	
	var traversed: Array[LocationRoom] = []
	
	while (rooms_to_traverse.size() > 0): 
		var current_room = rooms_to_traverse.pop_front()
		var current_path = paths.pop_front()
		
		if (current_room == end_room):
			return current_path
		
		# Add room to traversed
		traversed.append(current_room)
		
		# Iterate through doors to find connected rooms, add them to rooms_to_traverse IF they have not already been traversed
		var doors = current_room.get_children()
		for door: BackgroundDoor in doors:
			var connected_room = get_room_of_position(door.destination_door.global_position)
			
			# Prevent infinite loops
			if (traversed.has(connected_room)): 
				continue
			
			# Push next room onto traversal
			rooms_to_traverse.push_back(connected_room)
			
			# Push next path onto paths
			var current_path_clone = current_path.duplicate()
			current_path_clone.append(door)
			paths.push_back(current_path_clone)
	
	# Path not found
	return null

func get_room_of_position(position: Vector2) -> LocationRoom:
	for room: LocationRoom in rooms:
		if (room.area_contains_position(position)):
			return room
	
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func area_contains_position(position: Vector2) -> bool:
	var location_shape: RectangleShape2D = location_area.shape
	var location_size: Vector2 = location_shape.size
	var min_x = location_area.global_position.x - (location_size.x / 2)
	var max_x = location_area.global_position.x + (location_size.x / 2)
	var min_y = location_area.global_position.y - (location_size.y / 2)
	var max_y = location_area.global_position.y + (location_size.y / 2)
	
	return (position.x >= min_x and position.x <= max_x) and (position.y >= min_y and position.y <= max_y)
