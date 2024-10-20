class_name CameraShake
extends Node

## Camera Shake with trauma factor and details
## Most functions are static so they can be called
## Anywhere in the code base...
## For inspiration/source:
## https://www.youtube.com/watch?v=tu-Qe66AvtY

const DECAY = 0.5  # How quickly the shaking stops [0, 1].
const MAX_OFFSET = Vector2(64, 64)  # Maximum hor/ver shake in pixels.
const MAX_ROLL = 0.5  # Maximum rotation in radians (use sparingly).

static var trauma = 0.0  # Current shake strength.
static var trauma_power = 2  # Trauma exponent. Use [2, 3].

static var noise : FastNoiseLite
static var noise_y = 0

static var back_kick = Vector2.ZERO

static var final_offset = Vector2.ZERO
static var final_rotation = 0 # In RADIANS



## PUBLIC

## Add more shake, by a decimal amount since 1.0 is max
static func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)

## Kick the camera by a vector
static func kick(amount: Vector2):
	back_kick += amount



## PRIVATE

## Initalisation of noise
func _ready() -> void:
	noise = FastNoiseLite.new()
	randomize()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_lacunarity = 2
	noise.frequency = 0.01
	noise.fractal_gain = 0.5
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM

func _process(delta) -> void:
	# Recalculate offset per frame
	final_offset = Vector2.ZERO
	if trauma:
		trauma = max(trauma - DECAY * delta, 0)
		_shake()
	# Decay back kick back to zero offset
	back_kick = MathUtil.decay(back_kick, Vector2.ZERO, 5.0, delta)
	final_offset += back_kick # Kick by current kick amount

## Calculate shake noise
func _shake():
	var amount = pow(trauma, trauma_power)
	
	# print(amount)
	noise_y += 5
	final_rotation = MAX_ROLL * amount * noise.get_noise_2d(noise.seed, noise_y)
	final_offset.x = MAX_OFFSET.x * amount * noise.get_noise_2d(noise.seed + 105.5, noise_y)
	final_offset.y = MAX_OFFSET.y * amount * noise.get_noise_2d(noise.seed + 203.75, noise_y)
