class_name InGameUI
extends Control

@onready var clock = $Clock

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_current_IGT_s() -> float:
	return clock.get_current_IGT_s()

func pause_time():
	clock.pause_time()

func resume_time():
	clock.resume_time()
