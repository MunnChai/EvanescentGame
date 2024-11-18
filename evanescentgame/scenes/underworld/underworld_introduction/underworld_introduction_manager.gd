class_name UnderworldIntroductionManager
extends Node

## UNDERWORLD INTRODUCTION MANAGER
## General underworld progression logic FOR THE INTRODUCTION/"PROLOGUE"

const EVAN_SUCK_ANIMATION = preload("res://characters/player/evan_suck_animation.tscn")

## STATIC CUTSCENE TRIGGERS
## Set to true when that part of the cutscene should be triggered...
## Static variables are used so no specific instance is needed,
## TLDR compatible workaround so dialogue can change these...
static var fade_in := false # Trigger for FADE IN TO THE ENTIRE SCENE in intro
static var rise := false # Trigger for EVAN RISING FROM THE ROCKS in intro
static var end_intro := false # Trigger for ENDING THE LADY DEVIL INTERACTION

# Flag to check if the ending intro is already proceeding
var already_ending := false

## References
@onready var player = %Player

const SECONDS_FOR_SUCK_ANIMATION := 6.5
const SECONDS_AFTER_CUT_TO_BLACK := 1.0

func _ready() -> void:
	start_underworld_initial_intro() # Start the introduction!
func _process(_delta: float) -> void:
	if end_intro:
		end_underworld_intro()

func start_underworld_initial_intro() -> void:
	AmbientAudioManager.call_deferred("play_track", "res://scenes/underworld/audio/sfx/underground_creek.mp3") # Ideally we don't hard code this: set an export variable?
	AmbientAudioManager.call_deferred("set_pitch", 0.6)
	AmbientAudioManager.call_deferred("set_volume", 5)
	
	OverlayPanelManager.set_opacity(1.0) # Show panels
	%VignettePanel.show()
	
	# PLAYER IN POSITION
	player.is_input_active = false # No input during intro...
	player.position = %InitialSpawn.position # Make sure correct start position!
	
	# FADE IN FROM BLACK
	OverlayPanelManager.fade_in_to_scene(1.0)
	
	await get_tree().create_timer(1.5).timeout # Wait a little...
	
	# DIALOGUE SEQUENCE
	$World/Outdoor/SpawnDialogue.show_dialogue("evan_wake_up")
	
	while not fade_in:
		await get_tree().process_frame
	%VignettePanel.fade_in_to_scene(0.5) # Fade in SO WE CAN SEE THE SCENE!
	
	await get_tree().create_timer(0.5).timeout # Wait a little...
	
	MusicManager.play_track("res://scenes/underworld/audio/music/3-Chimes_loop.mp3") # Ideally we don't hard code this: set an export variable?
	
	while not rise:
		await get_tree().process_frame
	player.velocity = Vector2.UP * 100.0 # Rise! From the rocks...
	
	# Player automatically regains input at the end of the dialogue sequence...

## End the underworld intro.
func end_underworld_intro() -> void:
	if already_ending:
		return
	already_ending = true
	
	player.is_input_active = false # Steal input away, omniscient god robbery
	
	# Add the suck animation to the scene...
	var suck_anim_instance = EVAN_SUCK_ANIMATION.instantiate()
	player.add_child(suck_anim_instance)
	suck_anim_instance.global_position = player.sprite_2d.global_position
	suck_anim_instance.init() ## Initalize to make sure position is right and start the animation!
	
	# Hide the current actual player...
	player.hide_sprite() 
	
	await get_tree().create_timer(SECONDS_FOR_SUCK_ANIMATION).timeout # Wait a little...
	
	OverlayPanelManager.fade_out_scene(0.001) # Cut to black!!!
	
	await get_tree().create_timer(SECONDS_AFTER_CUT_TO_BLACK).timeout
	
	load_overworld() # Leave Hell

## Leave the underworld, go to the overworld
func load_overworld() -> void:
	SceneLoader.load_scene("res://old/top_level_scenes/overworld/overworld.tscn")
