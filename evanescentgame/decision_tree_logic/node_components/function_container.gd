class_name FunctionContainer
extends PanelContainer

@onready var function_name = $MarginContainer/VBoxContainer/FunctionName
@onready var param_container = $MarginContainer/VBoxContainer/ParamContainer

var param_hboxes: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Adding parameters
# Adds a parameter container to self
func add_parameter(selected_id: int = 0, value: String = ""):
	# Create container
	var param_hbox = HBoxContainer.new()
	
	# Create button to remove self
	var remove_button = Button.new()
	remove_button.text = "RemoveParam"
	remove_button.pressed.connect(on_param_remove_button_pressed.bind(param_hbox))
	remove_button.modulate = Color.RED
	
	# Create dropdown for parameter type
	# TODO: THIS IS STILL A WORK IN PROGRESS! I'm not exactly sure how I want to represent different types
	var option_button = OptionButton.new()
	option_button.add_item("String") 
	option_button.add_item("Vector2")
	option_button.add_item("Number")
	option_button.select(selected_id)
	
	var param_text_edit = TextEdit.new()
	param_text_edit.custom_minimum_size = Vector2(0, 40)
	param_text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	param_text_edit.text = value
	
	# Add components to container, add container to self, add container to array for easy access (for saving)
	param_hbox.add_child(remove_button)
	param_hbox.add_child(option_button)
	param_hbox.add_child(param_text_edit)
	param_container.add_child(param_hbox)
	param_hboxes.append(param_hbox)

func on_param_remove_button_pressed(param_hbox):
	param_hboxes.erase(param_hbox)
	param_hbox.queue_free()


func remove_self():
	queue_free()
