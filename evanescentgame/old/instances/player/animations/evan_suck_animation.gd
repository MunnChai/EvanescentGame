extends Node2D

## EVAN SUCK ANIMATION
## Designed for LEAVING HELL, from the INTRODUCTION

const OFFSET_FROM_EVAN_SPRITE: Vector2 = Vector2(-1, -40)

@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Apply offset and start the actual animation...
func init():
	# ASSUMING that the global position is Evan's sprite position...
	# Offset it so it replaces it correctly.
	global_position += OFFSET_FROM_EVAN_SPRITE
	show()
	play()

## Play the animation for the pneumatic mail tube!
func play() -> void:
	animation_player.play("tube_suck_1")
