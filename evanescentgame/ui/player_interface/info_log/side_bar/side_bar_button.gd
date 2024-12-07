class_name SideBarButton
extends Button

var entry: InfoLogEntryData = null
var button_entry_title: String = ""

signal selected(_entry)

func _on_pressed():
	selected.emit(entry)
