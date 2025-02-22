extends CanvasModulate

@export var in_game_ui: InGameUI # Munn: For the clock
@export var sky: Sprite2D # Munn: sky sprite

@export_category("Sky Properties")
@export var sky_night_color: Color
@export var sky_day_color: Color

@export_category("Modulate Properties")
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
func _process(delta: float):
	var current_time_s: float = in_game_ui.get_current_IGT_s()
	var current_time_h: float = current_time_s / (60 * 60) # Convert seconds to hours
	current_time_h = fmod(current_time_h, 24)
	
	update_modulate(current_time_h)
	update_sky(current_time_h)

# Updates the color filter on the world
func update_modulate(current_time_h: float):
	
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


func update_sky(current_time_h: float):
	if (current_time_h > day_start_time && current_time_h < day_end_time):
		# Bright
		sky.texture.gradient.colors[0] = sky_day_color
	elif (current_time_h > day_end_time && current_time_h < night_start_time):
		# Transition to dark
		var lerp_t = (current_time_h - day_end_time)/ (night_start_time - day_end_time)
		sky.texture.gradient.colors[0] = lerp(sky_day_color, sky_night_color, lerp_t)
	elif (current_time_h > night_start_time && current_time_h < night_end_time): # Munn: This doesn't work lol
		# Just dark
		sky.texture.gradient.colors[0] = sky_night_color
	elif (current_time_h > night_end_time && current_time_h < day_start_time): 
		# Transition to light
		var lerp_t = (current_time_h - night_end_time)/ (day_start_time - night_end_time) 
		sky.texture.gradient.colors[0] = lerp(sky_night_color, sky_day_color, lerp_t)
