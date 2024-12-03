extends Control

class_name Inventory

signal drop_item_from_inv

@onready var slots: Array[Node] = get_node("MarginContainer/GridContainer").get_children()

var items: Array[Item]

func update_slots():
	if (items.size() == 0):
		clear_all_slots()
		return
	
	for i in range(0, items.size()):
		slots[i].get_node("CenterContainer/Panel/item_display").texture = items[i].sprite_2d.texture
		slots[i].held_item = items[i]

func clear_all_slots():
	for i in range(0, 3):
		slots[i].get_node("CenterContainer/Panel/item_display").texture = null
