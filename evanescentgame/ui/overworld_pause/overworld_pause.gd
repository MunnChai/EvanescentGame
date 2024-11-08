extends Control

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	animation_player.play("RESET")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	escPressed()

func resume():
	get_tree().paused = false
	animation_player.play_backwards("blur")
	if !animation_player.is_playing():
		self.hide()

func pause():
	get_tree().paused = true
	self.show()
	animation_player.play("blur")

func escPressed():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func _on_resume_pressed():
	resume()

# acts as a restart button for now cuz no options menu yet :(
func _on_options_pressed():
	get_tree().reload_current_scene()
	resume()

func _on_quit_pressed():
	SceneLoader.load_scene("res://top_level_scenes/main_menu/main_menu.tscn")
