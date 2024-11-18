extends Control

@onready var animation_player = $AnimationPlayer
@onready var options_menu = $OptionsMenu
@onready var panel_container = $PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	options_menu.hide()
	#self.hide()
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

func escPressed():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused and !options_menu.is_open:
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
