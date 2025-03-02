class_name VentConnector
extends RoomConnector

## VENT
## - isLocked has no bearing on vents
## - isOpen describes if this vent is blocked/unblocked (obstruction!)
## - Ghosts can only travel through a vent if it is unobstructed
## - Humans recieve no interactable from vents
## - Blocked vents have no interactable

## OVERRIDE
func interact() -> void:
	if player.is_possessing: ## Human.
		pass ## Well, you don't even acknowledge it.
		## If we got here, something went terribly wrong.
	else:
		if is_open: ## Not blocked.
			_enter()
		else:
			pass ## How did we get here????
			## NOTE: Should this be a dialogue note?
