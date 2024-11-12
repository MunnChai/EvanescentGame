extends Control

@onready var animation_player = $AnimationPlayer
@export var pause_menu: Control

var is_open: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	escPressed()

func escPressed():
	if Input.is_action_just_pressed("esc") and is_open:
		is_open = false
		animation_player.play_backwards("slide_in")
		pause_menu.animation_player.play_backwards("slide_out")
