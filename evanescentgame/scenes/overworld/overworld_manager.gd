extends Node

const scene_duration = 540.0 # remade via UI timer

func load_underworld():
	SceneLoader.load_underworld()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	OverlayPanelManager.fade_in_to_scene(1) # Fade back in
	#await(get_tree().create_timer(scene_duration).timeout)
	#load_underworld()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
