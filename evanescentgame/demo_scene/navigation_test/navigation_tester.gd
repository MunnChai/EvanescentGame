extends Node2D

@export var npc: NPC

var mouse_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_pressed):
		mouse_pressed = true
		
		if (npc):
			npc.navigate_to(get_global_mouse_position(), null)
	elif (not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mouse_pressed):
		mouse_pressed = false

