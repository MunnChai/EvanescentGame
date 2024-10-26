extends Control
@onready var canvas_layer = $".."
@onready var loc_1 = $"../../LocationManager/Loc1"
@onready var loc_2 = $"../../LocationManager/Loc2"
@onready var loc_3 = $"../../LocationManager/Loc3"
@onready var player = $"../../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func button1_pressed():
	resume()
	player.global_position = loc_1.get_node("LocationExit").global_position

func button2_pressed():
	resume()
	player.global_position = loc_2.get_node("LocationExit").global_position

func button3_pressed():
	resume()
	player.global_position = loc_3.get_node("LocationExit").global_position

func _on_exit_pressed():
	resume()

func resume():
	get_tree().paused = false
	canvas_layer.visible = false
	
