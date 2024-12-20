class_name InteractableArea
extends Area2D

signal player_interacted

@onready var player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var interact_symbol = $InteractSymbol

var player_in: bool = false
var is_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_interact_symbol()

func interact():
	if not is_enabled:
		return
	
	player_interacted.emit()

func enable():
	get_node("CollisionShape2D").disabled = false
	is_enabled = true

func disable():
	is_enabled = false
	player.current_interactables.erase(self)
	get_node("CollisionShape2D").disabled = true
	hide_interact_symbol()

func _on_body_entered(body):
	if (body is Player):
		body.add_interactable(self)
		body.update_closest_interactable()


func _on_body_exited(body):
	if (body is Player):
		body.remove_interactable(self)
		body.update_closest_interactable()
		hide_interact_symbol()

func show_interact_symbol():
	if (is_enabled):
		interact_symbol.show()

func hide_interact_symbol():
	interact_symbol.hide()
