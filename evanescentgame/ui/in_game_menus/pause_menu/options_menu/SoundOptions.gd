extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_master_slider_value_changed(value):
	adjust_audio(0, value)
	

func _on_music_slider_value_changed(value):
	adjust_audio(2,value)


func _on_sfx_slider_value_changed(value):
	#adjusting both sfx and voice line audio tracks, can change later if needed
	adjust_audio(1, value)
	adjust_audio(3, value)

func adjust_audio(track, value):
	if(value == $MasterSlider.min_value):
		AudioServer.set_bus_mute(track, true)
	else:
		if(AudioServer.is_bus_mute(track)):
			AudioServer.set_bus_mute(track, false)
		
		AudioServer.set_bus_volume_db(track,value)


func _on_mute_check_toggled(toggled_on):
	if toggled_on:
		var min = $MasterSlider.min_value
		
		for n in 4:
			AudioServer.set_bus_mute(n, true)

	else:
		for n in 4:
			AudioServer.set_bus_mute(n, false)
