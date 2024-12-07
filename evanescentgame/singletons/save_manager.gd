extends Node

## SAVE MANAGER
## GLOBAL -- AUTOLOAD

const JSON_SAVE_FILE_PATH = "user://save.json"
const BINARY_SAVE_FILE_PATH = "user://game.save"

const EVAN_MEMORY_KEY = "memory"
const INFO_LOG_UNLOCK_KEY = "info_log_unlocks"

## GAME SAVE DATA:
## Dictionary with:
## { "memory": <Evan's Memory Dictionary>
##   "info_log_unlocks": <Info Log Unlocks Dictionary> 
##   "act": <Act Number from 1 to 3> }
## ...

## NOTE:
## Settings save in config or in save file?
## Any other relevant details to be saved?

var game_save_data: Dictionary = {}

## PUBLIC METHODS
## Currently using: JSON save methods

func save_game() -> void:
	# Gather save data from various game systems...
	var save_data = game_save_data
	
	save_data[INFO_LOG_UNLOCK_KEY] = InfoLogLogic.unlock_flags
	
	_save_game_to_json_file(save_data)

func reset_save() -> void:
	game_save_data = {}
	var save_data = {} 
	
	_save_game_to_json_file(save_data)

func load_game() -> void:
	var save_data = _load_game_from_json_file()
	
	# Put save data into game systems...
	game_save_data = save_data
	
	InfoLogLogic.unlock_flags = game_save_data.get(INFO_LOG_UNLOCK_KEY, {})



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
	
	log_message("FOR DEBUG PURPOSES: The loaded game save data dictionary is: " + str(game_save_data))
	log_message("Save files are located at " + OS.get_user_data_dir())
