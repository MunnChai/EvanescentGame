extends Control

const MAIN_SCENE: PackedScene = preload("res://main_scene/main_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_game():
	get_tree().change_scene_to_packed(MAIN_SCENE)
