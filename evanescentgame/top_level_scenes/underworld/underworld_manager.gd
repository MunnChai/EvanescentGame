extends Node

## General underworld progression logic

@onready var player = %Player

func _ready():
	start_underworld_initial_intro() # Demo logic, just start first seq...
	GameTemp.devil_initial_finished.connect(end_underworld_intro)

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

func end_underworld_intro():
	player.is_input_active = false # Steal input away, omniscient god robbery
	%OverlayPanel.fade_out_scene(1.0) # Fade away...
	await get_tree().create_timer(1.5).timeout # Wait a little...
	load_overworld() # Leave Hell

func load_overworld():
	SceneLoader.load_scene("res://top_level_scenes/overworld/overworld.tscn")
