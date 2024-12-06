extends Control
@onready var canvas_layer = $".."

@onready var button_container = $Panel/ButtonContainer
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

@export var location_manager: Node2D
@export var fade_seconds: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
	for location in location_manager.get_children():
		location.get_node("LocationExit").player_interacted.connect(show_ui)
		var button = Button.new()
		button.pressed.connect(teleport_to_location.bind(location))
		button.text = location.name
		button.add_theme_font_size_override("font_size", 6)
		button_container.call_deferred("add_child", button)

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
