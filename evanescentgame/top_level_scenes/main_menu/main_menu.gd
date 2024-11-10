extends Control

const PATH_TO_UNDERWORLD_INTRODUCTION = "res://top_level_scenes/underworld/underworld_introduction/underworld_introduction.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_game():
	SceneLoader.load_scene(PATH_TO_UNDERWORLD_INTRODUCTION)
