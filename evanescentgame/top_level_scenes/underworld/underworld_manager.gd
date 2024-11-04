class_name UnderworldManager
extends Node

## General underworld progression logic

@onready var player = %Player

static var fade_in := false
static var rise := false

func _ready():
	start_underworld_initial_intro() # Demo logic, just start first seq...
	GameTemp.devil_initial_finished.connect(end_underworld_intro)

func start_underworld_initial_intro():
	%OverlayPanel.show()
	%VignettePanel.show()
	# PLAYER IN POSITION
	player.is_input_active = false # No input during intro...
	player.position = %InitialSpawn.position
	# FADE IN FROM BLACK
	%OverlayPanel.fade_in_to_scene(1.0) # Fade in!
	await get_tree().create_timer(1.5).timeout # Wait a little...
	# DIALOGUE SEQUENCE
	$World/SpawnDialogue.show_dialogue("evan_wake_up")
	while not fade_in:
		await get_tree().process_frame
	%VignettePanel.fade_in_to_scene(0.5) # Fade in!
	while not rise:
		await get_tree().process_frame
	player.velocity = Vector2.UP * 100.0
	await get_tree().create_timer(1.0).timeout
	player.velocity = Vector2.RIGHT * 100.0
	await get_tree().create_timer(1.0).timeout
	player.velocity = Vector2.LEFT * 200.0
	# ok now the player can play the game
	# player.is_input_active = true - already called at end of dialogue

func end_underworld_intro():
	player.is_input_active = false # Steal input away, omniscient god robbery
	%OverlayPanel.fade_out_scene(1.0) # Fade away...
	await get_tree().create_timer(1.5).timeout # Wait a little...
	load_overworld() # Leave Hell

func load_overworld():
	SceneLoader.load_scene("res://top_level_scenes/overworld/overworld.tscn")
