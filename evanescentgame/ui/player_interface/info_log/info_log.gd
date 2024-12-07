class_name InfoLogLogic
extends Control

#region UNLOCK FLAGS (STATIC)

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

#endregion

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_init()
	$Entries.hide()
	
	print(json_entries)

func _init() -> void:
	load_all_json_entries_from_dir()

func _process(delta: float) -> void:
	_process_animation()
	
	if Input.is_action_just_pressed("toggle_log"):
		close() if is_open else open()

#region ENTRY LOADING/PROCESSING

## Path to folder with all JSON files...
const INFO_ENTRIES_PATH = "res://ui/player_interface/info_log/entries/"
## Path to node to instance for individual entries...
const INFO_LOG_ENTRY = preload("info_log_entry.tscn")

var json_entries: Array[InfoLogEntry] = []
var unlocked_json_entries: Array[InfoLogEntry] = []

const SIDE_BAR_BUTTON_PREFAB = preload("side_bar/side_bar_button.tscn")

@onready var people_entries = %PeopleEntries
@onready var places_entries = %PlacesEntries
@onready var things_entries = %ThingsEntries

var loaded := false

func load_all_json_entries_from_dir() -> void:
	var dir = DirAccess.open(INFO_ENTRIES_PATH)
	
	if not json_entries.is_empty(): # Never changes, only need to load once!
		return
	
	if dir == null:
		printerr("Error opening directory to load InfoLog JSON entries.")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		## FILE ACCESS
		var file = FileAccess.open(INFO_ENTRIES_PATH + file_name, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if not error == OK:
			printerr("Issue with loading a JSON info entry!")
			return
		
		## CREATE NEW ENTRY
		var new_entry: InfoLogEntry = INFO_LOG_ENTRY.instantiate()
		new_entry.init_from_json(json.data)
		add_child(new_entry)
		
		json_entries.append(new_entry)
		if new_entry.is_unlocked():
			unlocked_json_entries.append(new_entry)
		
		## Next!
		file_name = dir.get_next()

#endregion

#region OPEN/CLOSING

@onready var file_folder: AnimatedSprite2D = $FileFolder

var is_open := false

const FADE_BG_TIME := 0.1
var bg_fade_tween: Tween = null

func open() -> void:
	## Fade in BG panel
	_reset_tween()
	bg_fade_tween = create_tween()
	bg_fade_tween.tween_property($BgPanel, "modulate", Color(0, 0, 0, 1), FADE_BG_TIME)
	
	file_folder.play("file_flip_open")
	
	is_open = true
	get_tree().paused = true
	
	if loaded:
		return
	loaded = true
	
	## LOAD IN TO ENTRY NODES
	for entry: InfoLogEntry in json_entries:
		var new_side_bar_btn: SideBarButton = SIDE_BAR_BUTTON_PREFAB.instantiate()
		new_side_bar_btn.button_entry_title = entry.title
		new_side_bar_btn.entry = entry
		new_side_bar_btn.text = entry.sidebar_title
		new_side_bar_btn.selected.connect(_on_entry_selected)
		print("here")
		match entry.category:
			"people":
				people_entries.add_child(new_side_bar_btn)
			"places":
				places_entries.add_child(new_side_bar_btn)
			"things":
				things_entries.add_child(new_side_bar_btn)
			_:
				pass

## Open to a specific page or category, if it exists...
func open_to_entry(entry_id: String) -> void:
	open()
	go_to_entry(entry_id)

## Close the info log.
func close() -> void:
	is_open = false
	file_folder.play_backwards("file_flip_open")

## SHOW the visual for the interior of the FILE FOLDER
## when the right frame is hit.
const FRAME_TO_SHOW := 13
const FRAME_TO_HIDE := 12
func _process_animation() -> void:
	if file_folder.frame == FRAME_TO_SHOW:
		$Entries.show()
	if file_folder.frame == FRAME_TO_HIDE:
		$Entries.hide()

func _on_file_folder_animation_finished():
	if is_open:
		return
	
	## LOG CLOSED, ANIMATION DONE.
	_reset_tween()
	bg_fade_tween = create_tween()
	bg_fade_tween.tween_property($BgPanel, "modulate", Color(0, 0, 0, 0), FADE_BG_TIME)
	
	get_tree().paused = false

func _reset_tween() -> void:
	if bg_fade_tween != null:
		bg_fade_tween.kill()

#endregion

#region NAVIGATION

var current_entry: String = ""

## Go to a specific page or category...
func go_to_entry(entry_id: String) -> void:
	pass
	## GOTO LOGIC
func go_to_category(category_id: String) -> void:
	pass

#endregion

func _on_entry_selected(entry: InfoLogEntry) -> void:
	%Title.text = entry.title
	%Description.text = entry.description

func _on_people_btn_pressed():
	people_entries.show()
	places_entries.hide()
	things_entries.hide()
func _on_places_btn_pressed():
	people_entries.hide()
	places_entries.show()
	things_entries.hide()
func _on_things_btn_pressed():
	people_entries.hide()
	places_entries.hide()
	things_entries.show()
