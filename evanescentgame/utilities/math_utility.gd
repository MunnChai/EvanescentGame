class_name MathUtil

## Implements various more "advanced" mathematical
## components for use in other scripts.

## "Exponential decay" of value from start a to end b value,
## With decay constant, optimal range (1, 25)
## 1 is slow decay, 25 is fast decay
## For a framerate independent lerp
## See: https://www.youtube.com/watch?v=LSNQuFEDOyQ at 49:48
static func decay(a, b, decay_constant : float, delta : float):
	return b + (a - b) * exp(-decay_constant * delta)
