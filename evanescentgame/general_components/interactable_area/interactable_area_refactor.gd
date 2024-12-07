class_name InteractableAreaRefactor
extends InteractableArea

signal human_interacted
signal ghost_interacted

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_interact_symbol()

func interact():
	if not is_enabled:
		return
	
	if (player.is_possessing):
		human_interacted.emit()
	else:
		ghost_interacted.emit()
