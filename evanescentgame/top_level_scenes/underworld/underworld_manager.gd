extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_overworld():
	SceneLoader.load_scene("res://top_level_scenes/overworld/overworld.tscn")
