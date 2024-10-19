class_name Camera
extends Camera2D

## Camera with follow smoothing and average behaviour

# TODO
# Camera shake & camera kick
# Better "box" before moving
# Target switching
# Average position between weighted targets
# Custom camera paths/track/moving to predetermined nodes/positions

## EXPORTS
@export var target_node : Node2D

## CONSTANTS
const LERP_DECAY_CONST := 5.0 # How fast to lerp smooth to target

var is_lerping := true # Enable/disable linear interpolation smoothing
var target_position := Vector2.ZERO

var use_max_offset := true # Enable/disable wait until offset for follow
var max_offset := Vector2(16, 8) # Max offset vector before start follow

func _ready():
	pass

func _process(delta: float) -> void:
	_process_target_node(delta)
	if is_lerping:
		position = MathUtil.decay(position, target_position, LERP_DECAY_CONST, delta)
	else:
		position = target_position

## Sets target position to target node position
func _process_target_node(delta: float) -> void:
	if not use_max_offset:
		target_position = target_node.position
	
	# Bit buggy lol, redesign with better "box" mechanics...
	# Final - Original target's position
	# Assuming target stays the same! (Add check/state on change target...)
	var offset_vector: Vector2 = abs(target_node.position - position)
	if (offset_vector.x > max_offset.x) or (offset_vector.y > max_offset.y):
		target_position = target_node.position
