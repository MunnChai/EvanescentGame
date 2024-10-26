extends Node2D

signal player_exited

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_loc_1_player_exited():
	player_exited.emit()


func _on_loc_2_player_exited():
	player_exited.emit()


func _on_loc_3_player_exited():
	player_exited.emit()
