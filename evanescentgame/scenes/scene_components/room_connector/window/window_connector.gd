class_name WindowConnector
extends RoomConnector

## WINDOW
## - isOpen describes if this window is open to ghosts
## - isLocked describes if this window can be toggled open if it is closed
## - Ghosts that interact with the window travel through
## - Humans that interact with the window toggle open/closed, UNLESS it is locked,
##   in which case they unlock the window first IF they have a necessary key.

## OVERRIDE
func interact() -> void:
	if player.is_possessing:
		if is_locked:
			for key_id in key_ids:
				if player.currently_possessed_npc.inventory_contains_item_id(key_id):
					unlock()
					## Unlocked. Response!
					return
			
			## Locked. Response!
		else:
			close() if is_open else open()
	else:
		if is_open:
			_enter()
		else:
			pass ## Closed window... respond... or just not possible?
