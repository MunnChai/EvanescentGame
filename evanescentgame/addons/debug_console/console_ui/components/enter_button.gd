class_name EnterButton
extends Button

func enable() -> void:
	disabled = false
	focus_mode = Control.FOCUS_ALL

func disable() -> void:
	disabled = true
	focus_mode = Control.FOCUS_NONE
