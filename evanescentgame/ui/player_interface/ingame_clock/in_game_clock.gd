extends Label

# Start time in in game hours (eg. 9 = 9:00am, 9.5 = 9:30am, 15 = 3:00pm)
const START_TIME_IGT: float = 9 
# End time in in game hours (24 + 3 = 3:00am, the next day)
const END_TIME_IGT: float = 24 + 3 
# The time it takes for the day to pass, in real life seconds (eg. 4 * 60 + 30 = 4mins, 30secs)
const DAY_DURATION_IRL: float = 5 * 60
# eg. 1 IRL second * IGT_SECOND_MULTIPLIER = 1 IGT second
const IGT_SECOND_MULTIPLIER: float = ((END_TIME_IGT - START_TIME_IGT) * 60 * 60) / DAY_DURATION_IRL 

var timer_ended: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene.name == "Overworld": # change to (insert scene here)!!!
		text = " 12:00am"
		$Timer.wait_time = DAY_DURATION_IRL
		$Timer.start()
		$Timer.timeout.connect(load_underworld)
	else:
		# Maybe we can apply some funky effects here, like the numbers are constantly flipping through random times in the underworld?
		text = " 0:00xm"

func load_underworld():
	SceneLoader.load_underworld()

# Called every frame. 'delta' = elapsed time (used for timer things)
@warning_ignore("unused_parameter")
func _process(delta):
	if $Timer.is_stopped() == false:
		_update_timer($Timer.get_time_left())

# Returns time in seconds that have passed since the start
func get_current_IGT_s() -> float:
	var time_since_start = DAY_DURATION_IRL - $Timer.get_time_left()
	var in_game_time_since_start = time_since_start * IGT_SECOND_MULTIPLIER
	
	var time = in_game_time_since_start + (START_TIME_IGT * 60 * 60)
	return time

# Counting down overworld life visually, time_left is seconds left in the day in IRL time
func _update_timer(time_left: float) -> void:
	var time_since_start = DAY_DURATION_IRL - time_left
	var in_game_time_since_start = time_since_start * IGT_SECOND_MULTIPLIER
	
	var time = in_game_time_since_start + (START_TIME_IGT * 60 * 60)
	
	# technical time things
	var h = int((time) / (60 * 60))
	var m = int(fmod(time, 3600) / 60)
	
	# concatenation
	if (m < 10):
		m = "0" + str(m)
	else:
		m = str(m)
	if (h < 1):
		h = "12"
	else:
		h = str(fmod(h, 12))
	if (fmod(time, 3600 * 24) < 3600 * 12):
		text = " " + h + ":" + m + "am"
	else:
		text = " " + h + ":" + m + "pm"
