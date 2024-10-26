extends Node2D

@onready var canvas_layer = $CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_location_manager_player_exited():
	pause()

func pause():
	get_tree().paused = true
	canvas_layer.visible = true
