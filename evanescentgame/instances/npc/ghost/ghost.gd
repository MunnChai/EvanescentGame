class_name Ghost
extends NPC

var has_talked := false
@export var num : int = 1

@onready var starting_y := position.y

func on_player_interacted():
	if $InteractableArea.player.global_position.x < global_position.x:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
	
	if has_talked:
		signal_dialogue.emit("ghost_repeat_" + str(num))
		return
	
	has_talked = true
	signal_dialogue.emit("ghost_" + str(num))

func handle_npc_movement(delta: float):
	process_floating(delta)
	
	## TODO: Do we need navigation logic for LostSouls? 
	## If so, we should probably implement it here...
	
	move_and_slide()

## Float ghost up and down
var accumulated_time := 0.0
const FLOAT_MAGNITUDE = 3.0
const RATE_OF_FLOAT = 0.5
func process_floating(delta: float):
	accumulated_time += delta
	position = Vector2(position.x, starting_y + sin(PI * accumulated_time * RATE_OF_FLOAT) * FLOAT_MAGNITUDE)
