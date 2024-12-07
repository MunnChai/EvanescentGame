extends Node2D

@onready var interactable_area: InteractableArea = $InteractableArea
@onready var dialogue_emitter: DialogueEmitter = $DialogueEmitter
@onready var elevator_sprite: Sprite2D = $ElevatorSprite

const ELEVATOR_END_POSITION: Vector2 = Vector2(32, 0)
const ELEVATOR_MOVE_DURATION: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	interactable_area.disable()

func move_vending_machine():
	var tween = get_tree().create_tween()
	
	tween.tween_method(set_elevator_position, Vector2(0, 0), ELEVATOR_END_POSITION, ELEVATOR_MOVE_DURATION)
	tween.finished.connect(enable_elevator)

func interact_with_elevator():
	dialogue_emitter.show_dialogue("elevator_to_organization")

func set_elevator_position(given_position: Vector2):
	elevator_sprite.position = given_position

func enable_elevator():
	interactable_area.enable()
