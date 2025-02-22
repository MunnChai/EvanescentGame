extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var options_menu = $OptionsMenu
@onready var panel_container = $PanelContainer
@onready var fast_fwd_menu = $FastFwdMenu

@export var in_game_ui : Control

# Called when the node enters the scene tree for the first time.
func _ready():
	options_menu.hide()
	fast_fwd_menu.hide()
	fast_fwd_menu.in_game_ui = in_game_ui
	self.hide()
	animation_player.play("RESET")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	escPressed()

func resume():
	get_tree().paused = false
	animation_player.play_backwards("blur")

func pause():
	get_tree().paused = true
	#self.show()
	animation_player.play("blur")
	animation_player.animation_finished.connect(
		func(animation_name):
			for callable in animation_player.animation_finished.get_connections():
				animation_player.animation_finished.disconnect(callable["callable"])
			
			#hide() 
	)

func escPressed():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused and !options_menu.is_open and !fast_fwd_menu.is_open:
		resume()

func hide_menu(): 
	hide()
	options_menu.hide()
	fast_fwd_menu.hide()

func _on_resume_pressed():
	resume()

func _on_options_pressed():
	options_menu.is_open = true
	options_menu.show()
	
	options_menu.animation_player.play("slide_in")
	animation_player.play("slide_out")

func _on_quit_pressed():
	resume()
	SceneLoader.load_main_menu()

func _on_reset_pressed():
	resume()
	SceneLoader.load_underworld()

func _on_f_fwd_pressed():
	var curr_hour: float = floor(in_game_ui.get_current_IGT_s() / 60 / 60)
	fast_fwd_menu.is_open = true
	fast_fwd_menu.curr_hour = curr_hour
	fast_fwd_menu.show()
	
	fast_fwd_menu.h_slider.value = curr_hour
	fast_fwd_menu.update_slider_label(curr_hour)
	
	fast_fwd_menu.animation_player.play("slide_in")
	animation_player.play("slide_out")
