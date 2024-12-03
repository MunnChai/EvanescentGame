extends Node2D

const EVAN_SUCK_ANIMATION = preload("res://characters/player/evan_suck_animation.tscn")
const SECONDS_FOR_SUCK_ANIMATION: float = 6.5
const SECONDS_AFTER_CUT_TO_BLACK: float = 1.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var interactable_area = $InteractableArea

func _ready():
	if (!interactable_area.player_interacted.is_connected(teleport_to_overworld)): 
		interactable_area.player_interacted.connect(teleport_to_overworld)

func teleport_to_overworld():
	player.is_input_active = false
	
	while (player.velocity.length() > 0.5):
		await get_tree().create_timer(0.1).timeout
	
	# Teleporting sequence
	var suck_anim_instance = EVAN_SUCK_ANIMATION.instantiate()
	player.add_child(suck_anim_instance)
	suck_anim_instance.global_position = player.sprite_2d.global_position
	suck_anim_instance.init() ## Initalize to make sure position is right and start the animation!
	
	# Hide the current actual player...
	player.hide_sprite() 
	
	await get_tree().create_timer(SECONDS_FOR_SUCK_ANIMATION).timeout # Wait a little...
	
	OverlayPanelManager.fade_out_scene(0.001) # Cut to black!!!
	
	await get_tree().create_timer(SECONDS_AFTER_CUT_TO_BLACK).timeout
	
	SceneLoader.load_overworld()
