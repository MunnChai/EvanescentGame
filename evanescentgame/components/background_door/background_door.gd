class_name BackgroundDoor
extends Node2D

## Background Door
## Interact to go to the other door... interact again to come back.

@export var destination_door : BackgroundDoor
@export var fade_object : OverlayPanel

@onready var interactable_area : InteractableArea = $InteractableArea

func _ready() -> void:
	interactable_area.player_interacted.connect(_on_player_interacted)

func _on_player_interacted() -> void:
	# TEMP
	# Just move the player from here to where ever
	await _enter_process()

func teleport_to_next() -> void:
	var offset : Vector2 = interactable_area.player.global_position - global_position
	interactable_area.player.global_position = destination_door.global_position + offset

func _enter_process() -> void:
	interactable_area.player.is_input_active = false # Turn off input...
	
	# FADE OUT
	fade_object.fade_out_scene(0.2)
	
	await get_tree().create_timer(0.2).timeout
	
	teleport_to_next()
	
	# FADE IN
	fade_object.fade_in_to_scene(0.2)
	
	await get_tree().create_timer(0.2).timeout
	
	interactable_area.player.is_input_active = true

func _process(delta) -> void:
	pass
