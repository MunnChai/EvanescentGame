extends Control
@onready var canvas_layer = $".."

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

@export var location_manager: Node2D
@export var fade_seconds: float = 0.5

@export var dawn: NPC
@export var cousin: NPC
@export var colleague: NPC

var funeralChars : Array
var houseChars : Array
var cHouseChars : Array
var stationChars : Array
var orgChars : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
	#initializing the location values manually since the location_updated signal hasn't been called by any of the NPCs yet
	update_location_info("Dawn", dawn.current_location.name, "h")
	update_location_info("Carlos", cousin.current_location.name, "h")
	update_location_info("Kai", colleague.current_location.name, "h")
	
	for location in location_manager.get_children():
		location.get_node("LocationExit").player_interacted.connect(show_ui)

func show_ui():
	player.is_input_active = false
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func teleport_to_location(location: Location):
	resume()
	player.is_input_active = false
	OverlayPanelManager.fade_out_scene(fade_seconds)
	await get_tree().create_timer(fade_seconds).timeout
	
	if player.is_possessing:
		player.currently_possessed_npc.collision_mask = 0
		player.currently_possessed_npc.global_position = location.location_exit.global_position
		player.currently_possessed_npc.update_current_location()
	
	player.collision_mask = 0
	player.global_position = location.location_exit.global_position
	
	# REMOVES FRAME DROP????
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	player.call_deferred("set_collision_mask", 1)
	if (player.currently_possessed_npc):
		player.currently_possessed_npc.call_deferred("set_collision_mask", 1)
		player.currently_possessed_npc.move_to_ground()
	
	OverlayPanelManager.fade_in_to_scene(fade_seconds)
	await get_tree().create_timer(fade_seconds).timeout
	player.is_input_active = true

func _on_exit_pressed():
	resume()

func resume():
	hide()
	player.is_input_active = true


func _on_dawn_location_updated():
	if dawn.current_location and dawn.prev_location:
		update_location_info("Dawn", dawn.current_location.name, dawn.prev_location.name)

func _on_colleague_location_updated():
	if cousin.current_location and colleague.prev_location:
		update_location_info("Kai", colleague.current_location.name, colleague.prev_location.name)


func _on_cousin_location_updated():
	if cousin.current_location and cousin.prev_location:
		update_location_info("Carlos", cousin.current_location.name, cousin.prev_location.name)


func update_location_info(npcName, current, previous):
	match current:
		"Funeral Venue":
			print(npcName)
			funeralChars.append(npcName)
			displayCharLocations($Panel/GridContainer/FuneralLabel, funeralChars)
		"Evan's House":
			houseChars.append(npcName)
			displayCharLocations($Panel/GridContainer/HouseLabel, houseChars)
		"Cousin's House":
			cHouseChars.append(npcName)
			displayCharLocations($Panel/GridContainer/CHouseLabel, cHouseChars)
		"Police Station":
			stationChars.append(npcName)
			displayCharLocations($Panel/GridContainer/StationLabel, stationChars)
		"The Organization":
			orgChars.append(npcName)
			displayCharLocations($Panel/GridContainer/OrgLabel, orgChars)
			
	match previous:
		"Funeral Venue":
			funeralChars.erase(npcName)
			displayCharLocations($Panel/GridContainer/FuneralLabel, funeralChars)
		"Evan's House":
			houseChars.erase(npcName)
			displayCharLocations($Panel/GridContainer/HouseLabel, houseChars)
		"Cousin's House":
			cHouseChars.erase(npcName)
			displayCharLocations($Panel/GridContainer/CHouseLabel, cHouseChars)
		"Police Station":
			stationChars.erase(npcName)
			displayCharLocations($Panel/GridContainer/StationLabel, stationChars)
		"The Organization":
			orgChars.erase(npcName)
			displayCharLocations($Panel/GridContainer/OrgLabel, orgChars)


func displayCharLocations(label, chrArray):
	if len(chrArray) == 0:
		label.text = ""
	elif len(chrArray) == 1:
		label.text = chrArray[0] + " is here"
	elif len(chrArray) == 2:
		label.text = chrArray[0] + " and " + chrArray[1] + " are here"
	else:
		var textToDisplay = ""
		
		for i in len(chrArray):
			textToDisplay += chrArray[i]
			if i == len(chrArray) - 2:
				textToDisplay += ", and "
			elif i == len(chrArray) - 1:
				textToDisplay += " are here"
			else:
				textToDisplay += ", "

		label.text = textToDisplay




func _on_funeral_button_pressed():
	teleport_to_location(location_manager.get_children()[0])


func _on_house_button_pressed():
	teleport_to_location(location_manager.get_children()[1])


func _on_c_house_button_pressed():
	teleport_to_location(location_manager.get_children()[2])


func _on_station_button_pressed():
	teleport_to_location(location_manager.get_children()[3])


func _on_org_button_pressed():
	teleport_to_location(location_manager.get_children()[4])
