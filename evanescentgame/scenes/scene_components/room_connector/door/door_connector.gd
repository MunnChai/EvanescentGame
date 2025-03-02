class_name DoorConnector
extends RoomConnector

## DOOR
## - isOpen describes if this door is open or closed (free passage of ghosts)
## - isLocked describes if this door can be accessed by anyone or if it requires a key
## NOTE: What if door isOpen and isLocked?

## OVERRIDE
func interact() -> void:
	if player.is_possessing: ## Human.
		if is_locked: ## Need to unlock.
			for key_id in key_ids:
				if player.currently_possessed_npc.inventory_contains_item_id(key_id):
					unlock()
					## Unlocked. Response!
					return
			
			## Locked. Response!
		else:
			_enter()
	else:
		if is_open:
			_enter()
