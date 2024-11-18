extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' = elapsed time (used for location checking)
func _process(delta):
	if (!get_tree().current_scene):
		return
	
	if get_tree().current_scene.name.contains("Underworld"):
		text = ". . . . ? "
	elif get_tree().current_scene.name == "Overworld":
		text = "Land of the Living "
	else:
		text = "[unknown] "
