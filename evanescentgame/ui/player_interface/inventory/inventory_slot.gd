extends Panel

@export var texture: Texture2D

@onready var item_display = $CenterContainer/Panel/item_display

# Store the original texture (or any other identifier of the origin)
var original_texture : Texture2D

# For handling dragging
var dragging := false
var drag_offset := Vector2.ZERO

func _ready():
	item_display.texture = texture
	original_texture = item_display.texture
	self.connect("gui_input", Callable(self, "_on_gui_input"))

# Detect mouse button press to start dragging
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Start dragging when the left mouse button is pressed
			dragging = true
			drag_offset = event.position
			# Set up drag preview
			_get_drag_data(event.position)
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# Drop the item when the mouse button is released
			_drop_data(event.position, _get_drag_data(event.position))  # Pass both args

# This function handles the drag preview
func _get_drag_data(at_position):
	var data = {}
	data["origin_texture"] = original_texture
	
	# Create the drag preview texture
	var drag_texture = TextureRect.new()
	drag_texture.expand_mode = true
	drag_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	drag_texture.texture = item_display.texture
	drag_texture.size = Vector2(16, 16)
	
	# Center the image on the cursor
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.position = -0.5 * drag_texture.size
	
	# Set the drag preview
	set_drag_preview(control)
	
	return data

# Handle the drop (reset the texture or drop item as needed)
func _drop_data(at_position, data):
	# Always reset the texture when the item is dropped
	print("Item dropped")
	item_display.texture = original_texture
	# You can add other logic for what happens when the item is dropped
