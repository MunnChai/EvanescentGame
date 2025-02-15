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
	self.hide()
	animation_player.play("RESET")
	
	if in_game_ui:
		fast_fwd_menu.clock = in_game_ui.clock

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
		func():
			for callable in animation_player.animation_finished.get_connections():
				animation_player.animation_finished.disconnect(callable["callable"])
			
			hide()
	)

func escPressed():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused and !options_menu.is_open and !fast_fwd_menu.is_open:
		resume()

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

func _on_test_fwd_pressed():
	fast_fwd_menu.is_open = true
	fast_fwd_menu.show()
	fast_fwd_menu.h_slider.emit_signal("value_changed",9)
	
	fast_fwd_menu.animation_player.play("slide_in")
	animation_player.play("slide_out")
