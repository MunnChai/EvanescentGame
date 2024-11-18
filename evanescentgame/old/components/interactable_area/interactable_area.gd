class_name InteractableArea
extends Area2D

signal player_interacted

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]

var player_in: bool = false
var is_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not is_enabled:
		return
	
	# Check player.is_input_active to prevent interactions when no input
	if (player_in and player.is_input_active and Input.is_action_just_pressed("interact")):
		player_interacted.emit()

func enable():
	is_enabled = true

func disable():
	is_enabled = false
	$Label.visible = false

func _on_body_entered(body):
	if (body is Player):
		player_in = true
		$Label.visible = true


func _on_body_exited(body):
	if (body is Player):
		player_in = false
		$Label.visible = false
