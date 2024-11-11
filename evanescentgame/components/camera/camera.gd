class_name Camera
extends Camera2D

## Camera with follow smoothing and average behaviour

# TODO
# Better "box" before moving
# Target switching
# Average position between weighted targets
# Custom camera paths/track/moving to predetermined nodes/positions

## EXPORTS
@export var target_node : Node2D

## CONSTANTS
const LERP_DECAY_CONST := 5.0 # How fast to lerp smooth to target

var is_lerping := false # Enable/disable linear interpolation smoothing
var target_position := Vector2.ZERO
@onready var current_static_position := position

var use_max_offset := false # Enable/disable wait until offset for follow
var max_offset := Vector2(16, 8) # Max offset vector before start follow

func _ready():
	pass

func _process(delta: float) -> void:
	_process_target_node(delta)
	if is_lerping:
		current_static_position = MathUtil.decay(current_static_position, target_position, LERP_DECAY_CONST, delta)
	else:
		current_static_position = target_position
	
	# Apply CameraShake details
	position = current_static_position + CameraShake.final_offset
	rotation = CameraShake.final_rotation

## Sets target position to target node position
func _process_target_node(delta: float) -> void:
	if not use_max_offset:
		target_position = target_node.position
	
	# Bit buggy lol, redesign with better "box" mechanics...
	# Final - Original target's position
	# Assuming target stays the same! (Add check/state on change target...)
	var offset_vector: Vector2 = abs(target_node.position - current_static_position)
	if (offset_vector.x > max_offset.x) or (offset_vector.y > max_offset.y):
		target_position = target_node.position

func _physics_process(delta):
	# Apply CameraShake details
	position = current_static_position + CameraShake.final_offset
