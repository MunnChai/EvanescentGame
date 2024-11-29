class_name InfoLogEntryResource
extends Resource

## RESOURCE for InfoLogEntry
## Contains PERSISTENT data about what appears on this entry...

## TODO
## Make more EXTENSIBLE
## Logic for certain edge behaviour cases that might be needed (e.g. hide if certain flag)
## Jot notes system where each JOT NOTE has conditionals.
## How to do conditional logic in general?

## Title that appears on the main entry...
@export var title: String = "The Big Entry"
## Title that appears in the sidebar...
@export var side_bar_title: String = "Entry"

## Categories that this entry is classified under...
## Using list in case one entry fits under multiple categories...
## Most often "people", "places", or "things"
@export var categories: Array[String] = []

## Flags necessary for this entry to be unlocked...
@export var unlock_flags: Array[String] = []
func is_unlocked() -> bool:
	var unlocked := true
	for flag: String in unlock_flags:
		if InfoLogLogic.unlock_flags.get(flag, false) == false:
			unlocked = false
	return unlocked

## The blob brief paragraph description
@export_multiline var description: String = "Description"
