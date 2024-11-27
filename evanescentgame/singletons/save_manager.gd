extends Node

## SAVE MANAGER
## GLOBAL -- AUTOLOAD

const JSON_SAVE_FILE_PATH = "user://save.json"
const BINARY_SAVE_FILE_PATH = "user://game.save"

var game_save_data: Dictionary = {}

## PUBLIC METHODS

func save_game() -> void:
	# Gather save data from various game systems...
	var save_data = game_save_data
	
	_save_game_to_binary_file(save_data)

func load_game() -> void:
	var save_data = _load_game_from_binary_file()
	
	# Put save data into game systems...
	game_save_data = save_data



## PRIVATE

@onready var json: JSON = JSON.new()

## JSON
func _save_game_to_json_file(data: Dictionary) -> void:
	var json_string = json.stringify(data)
	
	# FileAccess.WRITE truncates the file when opened.
	var file = FileAccess.open(JSON_SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
	log_message("Successfully saved game save data to " + JSON_SAVE_FILE_PATH + ".")

func _load_game_from_json_file() -> Dictionary:
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

## BINARY
func _save_game_to_binary_file(data: Dictionary) -> void:
	var bytes: PackedByteArray = var_to_bytes(data)
	
	var file = FileAccess.open(BINARY_SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
	
	log_message("Successfully saved game save data to " + BINARY_SAVE_FILE_PATH + ".")
func _load_game_from_binary_file() -> Dictionary:
	if not FileAccess.file_exists(BINARY_SAVE_FILE_PATH):
		log_message("No existing save file at " + BINARY_SAVE_FILE_PATH + ", defaulting to empty save.")
		return {} # Default empty save file data
	
	var file_bytes: PackedByteArray = FileAccess.get_file_as_bytes(BINARY_SAVE_FILE_PATH)
	
	var data = bytes_to_var(file_bytes)
	
	log_message("Successfully loaded save file from " + BINARY_SAVE_FILE_PATH + ".")
	return data # Save file data



## DEBUG

func log_message(string: String) -> void:
	print("SAVE MANAGER | " + string)
func log_error(string: String) -> void:
	printerr("ERROR | SAVE MANAGER | " + string)

func _ready() -> void:
	load_game()
	
	# print(OS.get_data_dir()) # Directory where the file is stored.
	
	await get_tree().create_timer(1.0).timeout
	print(game_save_data)
	
	game_save_data["hello"] = false
	save_game()
