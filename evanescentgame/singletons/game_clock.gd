extends Node

@onready var clock = get_tree().get_first_node_in_group("clock")

func pause_time():
	clock = get_tree().get_first_node_in_group("clock")
	
	clock.pause_time()

func resume_time():
	clock = get_tree().get_first_node_in_group("clock")
	
	clock.resume_time()
