extends Control
@onready var canvas_layer = $".."
@onready var loc_1 = $"../../LocationManager/Loc1"
@onready var loc_2 = $"../../LocationManager/Loc2"
@onready var loc_3 = $"../../LocationManager/Loc3"
@onready var player = $"../../Player"

@export var location_manager: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	for location in location_manager.get_children():
		location.get_node("LocationExit").player_interacted.connect(show_ui)

func show_ui():
	get_tree().paused = true
	canvas_layer.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func button1_pressed():
	if player.is_possessing:
		player.currently_possessed_npc.global_position = loc_1.get_node("LocationExit").global_position

	player.global_position = loc_1.get_node("LocationExit").global_position
	resume()

func button2_pressed():
	if player.is_possessing:
		player.currently_possessed_npc.global_position = loc_2.get_node("LocationExit").global_position
	
	player.global_position = loc_2.get_node("LocationExit").global_position
	resume()

func button3_pressed():
	if player.is_possessing:
		player.currently_possessed_npc.global_position = loc_3.get_node("LocationExit").global_position
	
	player.global_position = loc_3.get_node("LocationExit").global_position
	resume()

func _on_exit_pressed():
	resume()

func resume():
	get_tree().paused = false
	canvas_layer.visible = false
