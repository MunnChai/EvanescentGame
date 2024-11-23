extends Control
@onready var canvas_layer = $".."

@onready var button_container = $Panel/ButtonContainer
@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

@export var location_manager: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	
	for location in location_manager.get_children():
		location.get_node("LocationExit").player_interacted.connect(show_ui)
		var button = Button.new()
		button.pressed.connect(teleport_to_location.bind(location))
		button.text = location.name
		button.add_theme_font_size_override("font_size", 10)
		button_container.call_deferred("add_child", button)

func show_ui():
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func teleport_to_location(location: Location):
	if player.is_possessing:
		player.currently_possessed_npc.global_position = location.location_exit.global_position + Vector2(0, 30)

	player.global_position = location.location_exit.global_position
	resume()

func _on_exit_pressed():
	resume()

func resume():
	hide()
