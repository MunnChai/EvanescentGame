extends Node

## General underworld progression logic

@onready var player = %Player

func _ready():
	start_underworld_initial_intro() # Demo logic, just start first seq...

func start_underworld_initial_intro():
	# PLAYER IN POSITION
	player.is_input_active = false # No input during intro...
	player.position = %InitialSpawn.position
	# FADE IN FROM BLACK
	await get_tree().create_timer(0.75).timeout # Wait a little...
	# DIALOGUE SEQUENCE
	$World/SpawnDialogue.show_dialogue("evan_wake_up")
	await get_tree().create_timer(0.75).timeout # Wait a little...
	%OverlayPanel.fade_in_to_scene(5.0) # Fade in!
	# await get_tree().create_timer(0.0).timeout
	# ok now the player can play the game
	# player.is_input_active = true - already called at end of dialogue

func load_overworld():
	SceneLoader.load_scene("res://top_level_scenes/overworld/overworld.tscn")
