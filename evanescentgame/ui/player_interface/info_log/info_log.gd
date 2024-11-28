class_name InfoLogLogic
extends Control

## STATE

var is_open := false
var current_entry: String = ""



## TRUE/FALSE FLAGS FOR CHECKING UNLOCKS
## Unlocks is STATIC since technically there is only
## ever ONE info log and unlocks loaded at one time!
static var unlock_flags: Dictionary = {}
static func is_unlocked(flag: String) -> bool:
	return unlock_flags.get(flag, false)
static func unlock_flag(flag: String) -> void:
	unlock_flags[flag] = true
	SaveManager.save_game()
static func lock_flag(flag: String) -> void:
	unlock_flags[flag] = false
	SaveManager.save_game()

## REFERENCES
@onready var file_folder: AnimatedSprite2D = $FileFolder


## PUBLIC METHODS

## CALLED TO INITALIZE THE LOG
## with unlocked entries, entry assets, etc.
func init() -> void:
	pass

## Open to main screen...
func open() -> void:
	is_open = true
	file_folder.play("file_flip_open")
func open_to_main() -> void:
	pass
## Open to a specific page or category, if it exists...
func open_to_entry(entry_id: String) -> void:
	open()
	go_to_entry(entry_id)

## Go to a specific page or category...
func go_to_entry(entry_id: String) -> void:
	if not is_unlocked(entry_id):
		printerr("Attempted to go to an entry with ID " + str(entry_id) + " which has not yet been unlocked.")
	## GOTO LOGIC
func go_to_category(category_id: String) -> void:
	pass

## Close the info log
func close() -> void:
	is_open = false
	file_folder.play_backwards("file_flip_open")



## DEBUG
func _ready():
	await get_tree().create_timer(1.0).timeout
	open()

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if is_open:
			close()
		else:
			open()
