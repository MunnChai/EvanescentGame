class_name OverlayPanel
extends Panel

## Fade in/out transition

@onready var opacity := modulate.a

func fade_in_to_scene(duration: float) -> void:
	fade_to_opacity(duration, 0.0, self)
func fade_out_scene(duration: float) -> void:
	fade_to_opacity(duration, 1.0, self)

## Generalised fade function for any CanvasItem
func fade_to_opacity(duration: float, target_opacity: float, target_node: CanvasItem) -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target_node, "modulate", Color(target_node.modulate, target_opacity), duration)
