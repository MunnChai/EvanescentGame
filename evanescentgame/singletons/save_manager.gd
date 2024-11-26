extends Node

## SAVE MANAGER
## GLOBAL -- AUTOLOAD

const JSON_SAVE_FILE_PATH = "user://save.json"

var game_save_data: Dictionary = {}

## PUBLIC METHODS

func save_game() -> void:
	# Gather save data from various game systems...
	var save_data = game_save_data
	
	_save_game_with_data(save_data)

func load_game() -> void:
	var save_data = _load_game_from_file()
	
	# Put save data into game systems...
	game_save_data = save_data



## PRIVATE

@onready var json: JSON = JSON.new()

func _save_game_with_data(data: Dictionary) -> void:
	var json_string = json.stringify(data)
	
	# FileAccess.WRITE truncates the file when opened.
	var file = FileAccess.open(JSON_SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
	log_message("Successfully saved game save data to " + JSON_SAVE_FILE_PATH + ".")

func _load_game_from_file() -> Dictionary:
	if not FileAccess.file_exists(JSON_SAVE_FILE_PATH):
		log_message("No existing save file at " + JSON_SAVE_FILE_PATH + ", defaulting to empty save.")
		return {} # Default empty save file data
	
	var file_string = FileAccess.get_file_as_string(JSON_SAVE_FILE_PATH)
	
	var error = json.parse(file_string)
	
	if error != OK:
		log_error("Issue parsing string from JSON save file! Defaulting to empty save file.")
		return {} # There was an error. Default to empty data.
	
	log_message("Successfully loaded save file from " + JSON_SAVE_FILE_PATH + ".")
	return json.data # Save file data

## DEBUG

func log_message(string: String) -> void:
	print("SAVE MANAGER | " + string)
func log_error(string: String) -> void:
	printerr("ERROR | SAVE MANAGER | " + string)

func _ready() -> void:
	pass
