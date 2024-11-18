extends Node2D

@export var condition_to_set: String
@export var button_name: String

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = button_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_button_1_pressed_true():
	DTConditionManager.set_condition("Npc1", condition_to_set, true)
	$Label.text = button_name + " (pressed)"
