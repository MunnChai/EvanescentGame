class_name LocationExit
extends Node2D

#@onready var nav_panel_scene: PackedScene = preload("res://ui/navigation_panel/navigation_panel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


 
func _on_interactable_player_interacted():
	get_tree().change_scene_to_file("res://ui/navigation_panel/navigation_panel.tscn")
