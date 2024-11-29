extends Control

@onready var options_menu = $OptionsMenu
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	options_menu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_game():
	SceneLoader.load_underworld_introduction()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_options_button_pressed():
	options_menu.is_open = true
	options_menu.show()

	options_menu.animation_player.play("slide_in")
	animation_player.play("slide_out")
