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
const INFO_ENTRIES_PATH = "res://ui/player_interface/info_log/entries/"

var unlocked_entry_resources: Array[InfoLogEntryResource] = []
var people_entries: Array[InfoLogEntryResource] = []
var places_entries: Array[InfoLogEntryResource] = []
var things_entries: Array[InfoLogEntryResource] = []

func init() -> void:
	## NOTE: Probably need optimization around here during loading.
	## Or load before start, and then select based on flags?
	
	unlocked_entry_resources = []
	
	var dir = DirAccess.open(INFO_ENTRIES_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var entry: InfoLogEntryResource = load(INFO_ENTRIES_PATH + file_name)
			if entry.is_unlocked():
				
				unlocked_entry_resources.append(entry)
				if entry.categories.has("people"):
					people_entries.append(entry)
				if entry.categories.has("places"):
					people_entries.append(entry)
				if entry.categories.has("things"):
					people_entries.append(entry)
				
			file_name = dir.get_next()
	
	for resource: InfoLogEntryResource in unlocked_entry_resources:
		print(resource.title)

## Open to main screen...
func open() -> void:
	init()
	$BgPanel.show()
	is_open = true
	file_folder.play("file_flip_open")
	print("Opened the info log!")
func open_to_main() -> void:
	open()
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
	print("Closed the info log!")
	$MarginContainer.hide()



## DEBUG
func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if is_open:
			close()
			unlock_flag("saw_funeral")
		else:
			open()



func _on_file_folder_animation_finished():
	if is_open:
		$MarginContainer.show()
	else:
		$BgPanel.hide()
