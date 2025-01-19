class_name ConsoleUI
extends Control

## CONSOLE UI
## Added to root node of game tree at runtime
## The UI for controling the console

## BUG: Potential interference between pause menus
## and console if pause_on_open is on 



signal command_submitted(string: String)

@onready var console_ui_root = %ConsoleUIRoot

@onready var output_text = %OutputText
@onready var text_input = %TextInput
@onready var enter_button: EnterButton = %EnterButton
@onready var close_button = %CloseButton

@onready var font_size = DebugConsole.CONFIG.font_size
@onready var pause_on_open = DebugConsole.CONFIG.pause_tree_when_open

var is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # The console never sleeps.
	
	## SETUP FONT SIZE
	output_text.add_theme_font_size_override("normal_font_size", font_size)
	output_text.add_theme_font_size_override("bold_font_size", font_size)
	output_text.add_theme_font_size_override("bold_italics_font_size", font_size)
	output_text.add_theme_font_size_override("italics_font_size", font_size)
	output_text.add_theme_font_size_override("mono_font_size", font_size)
	text_input.add_theme_font_size_override("font_size", font_size)
	enter_button.add_theme_font_size_override("font_size", font_size)
	close_button.add_theme_font_size_override("font_size", font_size)
	
	text_input.text_changed.connect(_on_text_input_changed)
	text_input.text_submitted.connect(_on_text_input_submitted)
	
	enter_button.disable() # Starts disabled.
	enter_button.pressed.connect(_on_enter_button_pressed)
	
	close_button.pressed.connect(close)
	
	## START HIDDEN
	close()

#region OPEN/CLOSE

## Toggles the console's visibility
func toggle() -> void:
	close() if is_open else open_and_focus()

## Opens the console
func open() -> void:
	console_ui_root.show()
	focus_mode = Control.FOCUS_ALL
	is_open = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if pause_on_open:
		get_tree().paused = true
## Open + focus on typing
func open_and_focus() -> void:
	open()
	text_input.grab_focus()
## Closes the console
func close() -> void:
	console_ui_root.hide() # HAVE TO SHOW/HIDE ROOT INSIDE OF THE CANVAS LAYER
	focus_mode = Control.FOCUS_NONE
	is_open = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if pause_on_open:
		get_tree().paused = false

#endregion

#region TEXT OUTPUT LOGIC

## Print, including new line character
func print_new_line(string: String) -> void:
	output_text.text += "\n" + string
## Print, without new line character
func print_string(string: String) -> void:
	output_text.text += string
func clear() -> void:
	output_text.text = ""

#endregion

#region TEXT INPUT LOGIC

## Enable the enter button if text actually contains something
## Otherwise, disable the enter button
func _on_text_input_changed(text: String) -> void:
	var text_content := text.strip_edges()
	if text_content.is_empty():
		enter_button.disable()
	else:
		enter_button.enable()

## If there is actual content, signal command and clear input
## Otherwise, do nothing
func _try_submit_text_input() -> void:
	var string = text_input.text.strip_edges()
	if string.is_empty(): # Literally nothing.
		return
	
	command_submitted.emit(string)
	text_input.text = ""
	enter_button.disable()
	text_input.grab_focus()

## UI ways to submit the text input
func _on_text_input_submitted(_text: String) -> void:
	_try_submit_text_input()
func _on_enter_button_pressed() -> void:
	_try_submit_text_input()

#endregion
