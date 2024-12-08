class_name BackgroundDoor
extends Node2D

## Background Door
## Player can pass in front of the door
## Interact to go to the other door... 
## ...interact with the other door to come back.



## SIGNALS

signal entered_this_door # Called at the start of the coroutine
signal exited_this_door # Called after input is returned after the coroutine

## Destination door.
@export var destination_door: BackgroundDoor = null
## Panel to fade in/out when the door transition is happening.
@export var fade_seconds: float = 0.15

# References
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var interactable_area : InteractableArea = $InteractableArea

func _ready() -> void:
	interactable_area.player_interacted.connect(_on_player_interacted)

## When the player interacts with the door...
func _on_player_interacted() -> void:
	_enter_process()

## Move the player to the destination door
func _teleport_to_next() -> void:
	var offset : Vector2 = Vector2(0, player.global_position.y - global_position.y) 
	
	if player.is_possessing:
		player.currently_possessed_npc.global_position = destination_door.global_position + offset + Vector2(0, 30)
		player.currently_possessed_npc.update_current_location()
	
	player.global_position = destination_door.global_position + offset

## Coroutine for moving the player from origin to destination doors
func _enter_process() -> void:
	entered_this_door.emit()
	player.is_input_active = false # Turn off input...
	
	OverlayPanelManager.fade_out_scene(fade_seconds)
	await get_tree().create_timer(fade_seconds).timeout
	
	_teleport_to_next()
	
	OverlayPanelManager.fade_in_to_scene(fade_seconds)
	await get_tree().create_timer(fade_seconds).timeout
	
	player.is_input_active = true # Transition over, here's input again...
	destination_door.exited_this_door.emit()
