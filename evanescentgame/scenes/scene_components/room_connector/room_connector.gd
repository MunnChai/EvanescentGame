class_name RoomConnector
extends Node2D

## ABSTRACT BASE CLASS (DO NOT INSTANCE)
## for things that connect rooms
## i.e. doors, windows, vents, etc.

## TODO:
## PROCESS checking!
## UNLOCK removes the lock???
## Standardize behaviour for NPCs

@export_category("CONNECTOR STATE & CONFIG")

## OPEN/CLOSED AND LOCKED/UNLOCKED STATE IS MIRRORED ACROSS ENTRANCE/DESTINATION
## Is this connector open or closed?
@export var is_open := false : set = _set_is_open
func _set_is_open(value: bool) -> void:
	is_open = value
	if destination_connector != null:
		destination_connector.is_open = value

## Is this connector locked? (Requires a key)
@export var is_locked := false : set = _set_is_locked
func _set_is_locked(value: bool) -> void:
	is_locked = value
	if destination_connector != null:
		destination_connector.is_locked = value

## If this connector is locked, requires ONE OF these key ids to pass through
## NOTE: Not automatically enforced with parity! Make sure both doors have the
## same key sets (if desired).
@export var key_ids: Array[String]

## Seconds to fade to black/fade out from black (Total transition time is 2x)
@export var fade_seconds := 0.15

@export_category("NECESSARY NODES")
## The other connector that this connector leads to
@export var destination_connector: RoomConnector
## An area that specifies where the interaction zone is
@export var interactable_area: InteractableArea
## A marker that specifies where the player will be teleported to when exiting via this connector
@export var exit_marker: Marker2D

## REFERENCES
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

## This connector was used to traverse somewhere
## EMITTED BY THE ENTRY CONNECTOR
signal entered_connector
## This connector was the destination of a traversal
## EMITTED BY THE DESTINATION CONNECTOR
signal exited_connector

## OVERRIDE WITH INTERACT BEHAVIOUR
func interact() -> void:
	pass

## Entering this connector...
func _enter() -> void:
	entered_connector.emit()
	player.is_input_active = false # Turn off input...
	
	OverlayPanelManager.fade_out_scene(fade_seconds)
	await get_tree().create_timer(fade_seconds).timeout
	
	destination_connector._exit() ## Leave from the destination

## Called on the exit DESTINATION CONNECTOR
func _teleport_to_here() -> void:
	if (exit_marker != null):
		player.global_position = exit_marker.global_position
		if player.is_possessing:
			player.currently_possessed_npc.global_position = exit_marker.global_position + Vector2(0, 30)
			player.currently_possessed_npc.update_current_location()
	else:
		player.global_position = global_position
		if player.is_possessing:
			player.currently_possessed_npc.global_position = global_position + Vector2(0, 30)
			player.currently_possessed_npc.update_current_location()

## Leaving this connector...
func _exit() -> void:
	_teleport_to_here() ## CALLED ON DESTINATION CONNECTOR
	
	OverlayPanelManager.fade_in_to_scene(fade_seconds)
	await get_tree().create_timer(fade_seconds).timeout
	
	player.is_input_active = true # Turn off input...
	
	exited_connector.emit()

func open() -> void:
	is_open = true

func close() -> void:
	is_open = false

func lock() -> void:
	is_locked = true

func unlock() -> void:
	is_locked = false

#region INIT

func _ready() -> void:
	_guarantee_interactable_area()
	if interactable_area != null:
		interactable_area.player_interacted.connect(interact)
	_guarantee_destination_connector()
	_guarantee_exit_marker()

func _guarantee_interactable_area() -> void:
	if interactable_area != null:
		return ## All good! We have one assigned.
	
	## Find one from immediate children
	for child in get_children(false):
		if child is InteractableArea:
			interactable_area = child
			return
	
	## None found. Alert issue!
	print("WARNING! Room connector \"" + name + "\" does not have an interactable area and cannot be interacted with.")

func _guarantee_destination_connector() -> void:
	if destination_connector == null:
		print("WARNING! Room connector \"" + name + "\" does not have a destination connector and will not function correctly.")

func _guarantee_exit_marker() -> void:
	if exit_marker == null:
		print("WARNING! Room connector\"" + name + "\" does not have an exit marker. Defaulting to the connector's global position.")

#endregion
