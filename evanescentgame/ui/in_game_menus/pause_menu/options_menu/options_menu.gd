extends Control

@onready var animation_player = $AnimationPlayer
@export var pause_menu: Control

var is_open: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("esc"):
		closeMenu()


func closeMenu():
	if is_open:
		is_open = false
		
		self.hide()
		
		animation_player.play_backwards("slide_in")
		get_parent().animation_player.play_backwards("slide_out")

func _on_button_pressed():
	closeMenu()
