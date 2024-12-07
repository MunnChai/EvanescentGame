extends CanvasLayer

@onready var keypad_text = %KeypadText
@onready var keypad_grid = %KeypadGrid

@export var correct_code: String = "1111"
@export var code_length: int = 4

const CODE_CHECK_WAIT_TIME: float = 0.5

var current_code: String = "":
	set(value):
		current_code = value
		keypad_text.text = current_code
	get:
		return current_code

var is_input_active: bool = true

signal correct_code_inputted

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_keypad()
	
	var i = 1
	for button in keypad_grid.get_children():
		button.pressed.connect(key_pressed.bind(i))
		i += 1

func key_pressed(number: int):
	if (not is_input_active):
		return
	
	current_code += str(number)
	
	if (current_code.length() == code_length):
		disable_input()
		
		await get_tree().create_timer(CODE_CHECK_WAIT_TIME).timeout
		
		if (is_code_correct()):
			# Show correct effects
			correct_code_inputted.emit()
			hide_keypad()
		else:
			# Show incorrect effects
			pass
		
		clear_keypad()
		enable_input()

func clear_keypad():
	current_code = ""

func is_code_correct() -> bool:
	if (current_code == correct_code):
		return true
	
	return false

func show_keypad():
	show()

func hide_keypad():
	hide()

func disable_input():
	is_input_active = false

func enable_input():
	is_input_active = true
