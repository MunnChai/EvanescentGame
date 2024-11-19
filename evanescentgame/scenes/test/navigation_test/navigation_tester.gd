extends Node2D

@export var npc: NPC
@export var locations: Node2D
var target_location: Location

var choosing_position: bool = false
var mouse_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in locations.get_children():
		if (node is Location):
			var button = Button.new()
			button.pressed.connect(set_target_location.bind(node))
			button.text = node.name
			$LocationButtons.add_child(button)

func set_choosing_position():
	choosing_position = true
	$IsNavigating.visible = true

func set_target_location(location: Location):
	target_location = location
	$CurrentLocation.text = "Current Location: " + location.name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_pressed):
		mouse_pressed = true
		
		if (npc and target_location and choosing_position):
			var mouse_position = get_global_mouse_position()
			npc.navigate_to(mouse_position)
			choosing_position = false
			$IsNavigating.visible = false
	elif (not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mouse_pressed):
		mouse_pressed = false

