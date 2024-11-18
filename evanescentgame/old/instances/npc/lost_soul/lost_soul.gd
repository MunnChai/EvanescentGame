class_name LostSoul 
extends NPC

var has_talked := false
@export var num : int = 1

@onready var starting_y := position.y

func on_player_interacted():
	if has_talked:
		dialogue_emitter.show_dialogue("lost_soul_repeat_" + str(num))
		return
	
	has_talked = true
	dialogue_emitter.show_dialogue("lost_soul_" + str(num))

func handle_npc_movement(delta: float):
	process_floating(delta)
	
	## TODO: Do we need navigation logic for LostSouls? 
	## If so, we should probably implement it here...
	
	move_and_slide()

## Float lost soul up and down
var accumulated_time := 0.0
const FLOAT_MAGNITUDE = 3.0
const RATE_OF_FLOAT = 0.5
func process_floating(delta: float):
	accumulated_time += delta
	position = Vector2(position.x, starting_y + sin(PI * accumulated_time * RATE_OF_FLOAT) * FLOAT_MAGNITUDE)
