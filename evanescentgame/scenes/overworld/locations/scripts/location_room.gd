class_name LocationRoom
extends CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func area_contains_position(position: Vector2) -> bool:
	var location_shape: RectangleShape2D = shape
	var location_size: Vector2 = location_shape.size
	var min_x = global_position.x - (location_size.x / 2)
	var max_x = global_position.x + (location_size.x / 2)
	var min_y = global_position.y - (location_size.y / 2)
	var max_y = global_position.y + (location_size.y / 2)
	
	return (position.x >= min_x and position.x <= max_x) and (position.y >= min_y and position.y <= max_y)
