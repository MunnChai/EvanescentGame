extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' = elapsed time (used for location checking)
func _process(delta):
	if SceneLoader.scene_to_load_path == "res://top_level_scenes/underworld/underworld_introduction/underworld_introduction.tscn":
		text = ". . . . ? "
	elif SceneLoader.scene_to_load_path == "res://top_level_scenes/overworld/overworld.tscn":
		text = "Land of the Living "
	else:
		text = "[unknown] "
