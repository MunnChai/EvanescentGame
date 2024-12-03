extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	if(DisplayServer.window_get_mode() == 3):
		$FScreenCheck.button_pressed = true;
		
	if(DisplayServer.window_get_size() == Vector2i(640,360)):
		$ResOptions.selected = 0
	elif(DisplayServer.window_get_size() == Vector2i(1280,720)):
		$ResOptions.selected = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_res_options_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(640,360))
		1:
			DisplayServer.window_set_size(Vector2i(1280,720))
	



func _on_f_screen_check_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(3)

	if not toggled_on:
		DisplayServer.window_set_mode(0)
