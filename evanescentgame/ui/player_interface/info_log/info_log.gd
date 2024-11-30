class_name InfoLogLogic
extends Control

## STATE

var is_open := false
var current_entry: String = ""

var tween: Tween = null

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

## Path to folder with all JSON files...
const INFO_ENTRIES_PATH = "res://ui/player_interface/info_log/entries/"
var json_entries = []
var unlocked_json_entries = []

func is_entry_unlocked(entry: Dictionary) -> bool:
	var add := true
	for flag in entry.get("unlock_flags", []):
		if not is_unlocked(flag):
			add = false
	
	#var strike_out := true
	#for flag in entry.get("strike_out_flags", []):
		#if not is_unlocked(flag):
			#strike_out = false
	
	return add

func init() -> void:
	## NOTE: Probably need optimization around here during loading.
	## Or load before start, and then select based on flags?
	
	var dir = DirAccess.open(INFO_ENTRIES_PATH)
	if dir and json_entries.is_empty():
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var file = FileAccess.open(INFO_ENTRIES_PATH + file_name, FileAccess.READ)
			
			var json = JSON.new()
			
			var data = json.parse(file.get_as_text())
			
			file.close()
			
			if not data == OK:
				printerr("Issue with loading a JSON info entry!")
				return
			
			json_entries.append(json.data)
			if is_entry_unlocked(json.data):
				unlocked_json_entries.append(json.data)
			
			file_name = dir.get_next()
	
	print(json_entries)

const FADE_BG_TIME := 0.1

## Open to main screen...
func open() -> void:
	init()
	
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property($BgPanel, "modulate", Color(0, 0, 0, 1), FADE_BG_TIME)
	
	is_open = true
	file_folder.play("file_flip_open")
	print("Opened the info log!")
	
	get_tree().paused = true
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
	# $MarginContainer.hide()



## DEBUG
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$BgPanel.process_mode = Node.PROCESS_MODE_ALWAYS

const FRAME_TO_SHOW := 13
const FRAME_TO_HIDE := 12

func _process(delta):
	if Input.is_action_just_pressed("open_log"):
		if is_open:
			close()
		else:
			open()
	
	if file_folder.frame == FRAME_TO_SHOW:
		$Entries.show()
	if file_folder.frame == FRAME_TO_HIDE:
		$Entries.hide()



func _on_file_folder_animation_finished():
	if is_open:
		# $MarginContainer.show()
		pass
	else:
		if tween != null:
			tween.kill()
		tween = create_tween()
		tween.tween_property($BgPanel, "modulate", Color(0, 0, 0, 0), FADE_BG_TIME)
		get_tree().paused = false

