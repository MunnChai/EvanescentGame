extends Panel

# Reference to the item sprite within this slot
@onready var item_display = $CenterContainer/Panel/item_display

var mouse_is_hovering : bool = false
var holding_item : bool = false
var held_item : Item

const drag_offset : Vector2 = Vector2(16, 16)

signal drop_item

func _physics_process(delta):
	_handle_drag_drop()

func _handle_drag_drop():
	# picking up item
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and mouse_is_hovering:
		holding_item = true
	
	# dropping item
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and holding_item:
		holding_item = false
		if (mouse_is_hovering):
			_return_item()
		else:
			_drop_item()
	
	
	# displaying item
	if holding_item:
		item_display.position = get_global_mouse_position() - drag_offset

func _return_item():
	item_display.position = Vector2(0,0)

func _drop_item():
	drop_item.emit(held_item)
	item_display.position = Vector2(0,0)

func _on_mouse_entered():
	mouse_is_hovering = true

func _on_mouse_exited():
	mouse_is_hovering = false
