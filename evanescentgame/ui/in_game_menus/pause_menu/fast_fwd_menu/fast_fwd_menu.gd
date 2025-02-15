extends Control

# Start time in in game hours (eg. 9 = 9:00am, 9.5 = 9:30am, 15 = 3:00pm)
const START_TIME_IGT: float = 9 
# End time in in game hours (24 + 3 = 3:00am, the next day)
const END_TIME_IGT: float = 12 + 9
# The time it takes for the day to pass, in real life seconds (eg. 4 * 60 + 30 = 4mins, 30secs)
const DAY_DURATION_IRL: float = 5 * 60
# eg. 1 IRL second * IGT_SECOND_MULTIPLIER = 1 IGT second
const IGT_SECOND_MULTIPLIER: float = ((END_TIME_IGT - START_TIME_IGT) * 60 * 60) / DAY_DURATION_IRL 

# Based on random testing to see what feels ok... adjust as needed
const PHYS_MULTIPLIER : float = 12
const current_hour : float = 12

@onready var animation_player = $AnimationPlayer
@export var h_slider: Control
@export var pause_menu: Control

# Set in pause_menu ready() func
var clock: Label

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

func _speed_up():
	for i in range(1, 1000):
		await get_tree().create_timer(1).timeout
		
		# Ex. if set to 2.0 the game runs twice as fast; if set to 0.5 the game runs half as fast.
		Engine.time_scale = i
		
		# godot docs recommend this value be at least 60
		Engine.physics_ticks_per_second = min(PHYS_MULTIPLIER * i, 60)

func _on_button_pressed():
	closeMenu()


func _on_h_slider_value_changed(value):
	if value < current_hour:
		h_slider.value = current_hour
