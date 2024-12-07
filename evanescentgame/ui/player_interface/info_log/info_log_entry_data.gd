class_name InfoLogEntryData
extends Node

## An instance of a InfoLog entry

## SAMPLE JSON
#{
  #"id": "evan",	snake_case ID to track entries, unique!
  #"title": "Evan",	Name to show in ENTRY
  #"sidebar_title": "Evan",	Name to show in SIDEBAR navigation
  #“category”: “people”,	Name of the CATEGORY this entry belongs in 
  #"description": "You?\nPresumably.",	Permanent description
  #"unlock_flags": ["met_devil"],		Necessary flags to qualify for unlock
  #"jot_notes": [
	#{
	  #"content": "Is a ghost.", 			Jot notes actual text
	  #"unlock_flags": []				Jot note unlock requirements
	#},
	#{
	  #"content": "Has a wife.",
	  #"unlock_flags": ["met_wife"]
	#}
  #]
#}

func init_from_json(data: Dictionary) -> void:
	id = data["id"]
	title = data["title"]
	sidebar_title = data["sidebar_title"]
	category = data["category"]
	description = data["description"]
	unlock_flags = data["unlock_flags"]
	
	for jot_note in data["jot_notes"]:
		var new_jot_note: JotNote = JotNote.new(jot_note["content"], jot_note["unlock_flags"])
		jot_notes.append(new_jot_note)

## Is THIS InfoLogEntry unlocked?
func is_unlocked() -> bool:
	var unlocked := true
	for flag in unlock_flags:
		if not InfoLogLogic.is_unlocked(flag):
			unlocked = false
	return unlocked



var id: String = ""
var title: String = ""
var sidebar_title: String = ""
var category: String = ""
var description: String = ""
var unlock_flags: Array = [] # Of string...
var jot_notes: Array[JotNote] = []

class JotNote:
	var content: String = ""
	var unlock_flags: Array = [] # Of string...
	
	func _init(_content: String, _unlock_flags: Array) -> void:
		content = _content
		unlock_flags = _unlock_flags
	
	## Is THIS JotNote unlocked?
	func is_unlocked() -> bool:
		var unlocked := true
		for flag in unlock_flags:
			if not InfoLogLogic.is_unlocked(flag):
				unlocked = false
		return unlocked
