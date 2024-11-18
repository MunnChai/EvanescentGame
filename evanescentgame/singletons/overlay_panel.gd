extends Node

const OVERLAY_PANEL_SCENE = preload("res://components/overlay_panel/overlay_panel.tscn")

var overlay_panel: OverlayPanel
var canvas_layer: CanvasLayer

func _ready():
	overlay_panel = OVERLAY_PANEL_SCENE.instantiate()
	overlay_panel.modulate.a = 0
	overlay_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE # So it does not block mouse actions (eg. clicking the play button)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(overlay_panel)
	call_deferred("add_child", canvas_layer)

func set_opacity(opacity: float) -> void:
	overlay_panel.modulate.a = opacity

func fade_in_to_scene(duration: float) -> void:
	fade_to_opacity(duration, 0.0, overlay_panel)
func fade_out_scene(duration: float) -> void:
	fade_to_opacity(duration, 1.0, overlay_panel)

## Generalised fade function for any CanvasItem
func fade_to_opacity(duration: float, target_opacity: float, target_node: CanvasItem) -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target_node, "modulate", Color(target_node.modulate, target_opacity), duration)
