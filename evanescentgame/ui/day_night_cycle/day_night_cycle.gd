extends CanvasModulate

@export var in_game_ui: InGameUI # Munn: For the clock

@export var night_color: Color = Color(0.5, 0.5, 0.8)
@export var day_color: Color = Color(1, 1, 1)

@export var day_start_time = 8 # Time when the sky finishes brightening
@export var day_end_time = 12 + 5 # Time when the sky begins to darken
@export var night_start_time = 12 + 7 # Time when the sky finishes darkening
@export var night_end_time = 6 # Time when the sky begins to brighten

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_time_s: float = in_game_ui.get_current_IGT_s()
	var current_time_h: float = current_time_s / (60 * 60) # Convert seconds to hours
	current_time_h = fmod(current_time_h, 24)
	
	if (current_time_h > day_start_time && current_time_h < day_end_time):
		# Bright
		color = day_color
	elif (current_time_h > day_end_time && current_time_h < night_start_time):
		# Transition to dark
		var lerp_t = (current_time_h - day_end_time)/ (night_start_time - day_end_time)
		color = lerp(day_color, night_color, lerp_t)
	elif (current_time_h > night_start_time && current_time_h < night_end_time): # Munn: This doesn't work lol
		# Just dark
		color = night_color
	elif (current_time_h > night_end_time && current_time_h < day_start_time): 
		# Transition to light
		var lerp_t = (current_time_h - night_end_time)/ (day_start_time - night_end_time) 
		color = lerp(night_color, day_color, lerp_t)
	
	
