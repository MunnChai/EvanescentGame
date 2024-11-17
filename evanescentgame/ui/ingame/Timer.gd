extends Label

# the timer counts DOWN, so set the start and end times accordingly
# (e.g. 9am-3am would be 1170 - 630, as it is (or was)
# (wrt seconds in irl time, in game it's 720sec/day) 
const start_time = 1170
const end_time = 630

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene.name == "Overworld": # change to (insert scene here)!!!
		text = " 12:00am"
		if (start_time - end_time > 0):
			$Timer.wait_time = start_time
		else:
			$Timer.wait_time = 1
		$Timer.start()
	else:
		text = " 0:00xm"

# Called every frame. 'delta' = elapsed time (used for timer things)
@warning_ignore("unused_parameter")
func _process(delta):
	if $Timer.is_stopped() == false:
		_update_timer($Timer.get_time_left())
		if ($Timer.get_time_left() <= end_time):
			# cool things may happen here, but for right now just
			SceneLoader.load_scene("res://top_level_scenes/underworld/underworld.tscn")
	else:
		pass

# Counting down overworld life visually
func _update_timer(duration: float):
	var time = 720 - (duration - (int(duration / 720) * 720))
	if (time - int(time)) > 0.5:
		time = int(time) + 0.5
	else:
		time = float(int(time))
	
	# technical time things
	var h = int((time * 2) / 60)
	var m = int((time * 2) - (60 * h))
	
	# concatenation
	if (m < 10):
		m = "0" + str(m)
	else:
		m = str(m)
	if (h < 1):
		h = "12"
	elif (h > 12):
		h = str(h - 12)
	else:
		h = str(h)
	if (time < 360):
		text = " " + h + ":" + m + "am"
	else:
		text = " " + h + ":" + m + "pm"
