extends Control

class_name Inventory

@onready var npc: NPC = get_parent().get_parent()
@onready var slots: Array[Node] = get_node("MarginContainer/GridContainer").get_children()

var items: Array[Item]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_slots():
	for i in range(0, items.size()):
		slots[i].item_visual.texture = items[i].sprite_texture
