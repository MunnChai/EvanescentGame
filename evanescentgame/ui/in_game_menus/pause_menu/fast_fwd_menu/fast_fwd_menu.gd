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
const PHYS_MULTIPLIER: float = 12
const MAX_TIME_SCALE: float = 20

@onready var animation_player = $AnimationPlayer
@export var value_label: Label
@export var h_slider: Control
@export var pause_menu: Control

var in_game_ui
var is_open: bool
var curr_hour: float

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

func _on_f_fwd_button_pressed():
	if (h_slider.value > curr_hour):
		speed_up()
	else:
		pass # do nothing for now when they leave slider at curr_hour


func speed_up():
	var target_s = h_slider.value * 60 * 60
	var offset_s = target_s - MAX_TIME_SCALE * 10
	var mid_point = 0.5
	var base_max_interval = 2.0 # normalize interval to range from [0, base_max_interval]
	
	closeMenu()
	await get_tree().create_timer(0.25).timeout # things break without this...
	get_parent().resume()
	
	var current_s: float = in_game_ui.get_current_IGT_s()
	while current_s < offset_s:
		var progress: float = (current_s - curr_hour * 60 * 60) / (offset_s- curr_hour * 60 * 60)
		var normalized_progress: float = abs(progress - mid_point) * 2 # ranges from [0, 1]
		
		var interval: float = normalized_progress * base_max_interval
		await get_tree().create_timer(interval).timeout
		
		var time_scale = lerp(1.0, MAX_TIME_SCALE, 1.0 - normalized_progress)
		Engine.time_scale = time_scale
		# godot docs recommend this value be at least 60
		Engine.physics_ticks_per_second = max(PHYS_MULTIPLIER * time_scale, 60)
		
		current_s = in_game_ui.get_current_IGT_s()
	
	print("end of loop")
	# Ensure engine parameters set back to normal
	Engine.time_scale = 1
	Engine.physics_ticks_per_second = 60 

func _on_h_slider_value_changed(value):
	if value < curr_hour:
		h_slider.value = curr_hour
	update_slider_label(h_slider.value)

func update_slider_label(value):
	# Convert 24-hour to AM/PM
	var display_hour = int(value)
	var suffix = "AM" if display_hour < 12 else "PM"
	if display_hour > 12:
		display_hour -= 12
	elif display_hour == 0:
		display_hour = 12  # if we ever do midnight
		
	value_label.text = str(display_hour) + " " + suffix

	# scale in VBoxContainer in layout->transform
	var scale: float = 0.5
	
	# ticks in slider don't cover whole slider, so add offset for label
	var offset: float = value * 0.41
	
	# Position label dynamically above the slider thumb
	var slider_min: float = h_slider.global_position.x
	var slider_max: float = slider_min + h_slider.size.x * scale
	var percentage: float = (value - START_TIME_IGT) / (END_TIME_IGT - START_TIME_IGT)
	value_label.global_position.x = slider_min + (percentage * h_slider.size.x * scale) - offset
