class_name InfoLogLogic
extends Control

## TODO
## - A NOTIFICATION for when the Case Log is updated.
## - LINKS within the Case Log to other entries.

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
static func clear() -> void:
	unlock_flags = {}
	SaveManager.save_game()

#endregion

## DEBUG COMMANDS
func _setup_debug() -> void:
	var info_log_cmd = func (args: PackedStringArray):
		if len(args) < 1:
			Logger.log("infolog expects subcommand: lock, unlock, flags, clear")
			return
		var sub_cmd := args[0]
		match sub_cmd:
			"lock":
				if len(args) < 2:
					Logger.log_error("infolog lock needs at least one flag: infolog lock <flag1> <flag2> ...")
				else:
					var remaining_args := args.slice(1)
					for arg in remaining_args:
						InfoLogLogic.lock_flag(arg)
						Logger.log("Locked InfoLog flag: " + arg + ".")
			"unlock":
				if len(args) < 2:
					Logger.log_error("infolog unlock needs at least one flag: infolog unlock <flag1> <flag2> ...")
				else:
					var remaining_args := args.slice(1)
					for arg in remaining_args:
						InfoLogLogic.unlock_flag(arg)
						Logger.log("Unlocked InfoLog flag: " + arg + ".")
			"flags": ## PRINT FLAGS
				Logger.log("InfoLog Unlock Flags:")
				var output := ""
				var dict = InfoLogLogic.unlock_flags
				for flag in dict:
					var pair: String = flag + ": " + str(dict[flag])
					if output.is_empty():
						output += pair
					else:
						output += "\n%s" % pair
				if not output.is_empty():
					Logger.log(output)
			"clear": ## CLEAR FLAGS
				InfoLogLogic.clear()
				Logger.log("Cleared InfoLog Unlock Flags.")
	
	DebugConsole.register("infolog", info_log_cmd)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # No pausing!
	load_all_json_entries_from_dir()
	$Entries.hide()
	clear_entry_view()
	hide()
	
	_setup_debug()

func _process(delta: float) -> void:
	_process_animation()
	if Input.is_action_just_pressed("toggle_log"):
		close() if is_open else open()

#region ENTRY LOADING/PROCESSING

## Path to folder with all JSON files...
const ENTRIES_PATH = "res://ui/player_interface/info_log/entries/"
## Path to node to instance for individual entries...
const ENTRY_DATA_TSCN = preload("info_log_entry_data.tscn")

@onready var entry_data = %EntryData
var entry_data_nodes: Array[InfoLogEntryData] = []

func load_all_json_entries_from_dir() -> void:
	var file_paths := FileUtil.get_all_file_paths_in_dir(ENTRIES_PATH, "json", [])
	
	for path: String in file_paths:
		load_json_entry_from_file_path(path)
func load_json_entry_from_file_path(path: String) -> void:
	var new_entry: InfoLogEntryData = ENTRY_DATA_TSCN.instantiate()
	new_entry.init_from_json(FileUtil.parse_json_file_at_path_to_dict(path))
	entry_data.add_child(new_entry)
	entry_data_nodes.append(new_entry)

#endregion

#region OPEN/CLOSING

@onready var file_folder: AnimatedSprite2D = $FileFolder

var is_open := false

const FADE_BG_TIME := 0.1
var bg_fade_tween: Tween = null

const SIDE_BAR_BUTTON_PREFAB = preload("side_bar/side_bar_button.tscn")

@onready var people_btn = %PeopleBtn
@onready var places_btn = %PlacesBtn
@onready var things_btn = %ThingsBtn

@onready var people_entries = %PeopleEntries
@onready var places_entries = %PlacesEntries
@onready var things_entries = %ThingsEntries

func open() -> void:
	show()
	## VISUALS
	## Fade in BG panel
	_reset_tween()
	bg_fade_tween = create_tween()
	bg_fade_tween.tween_property($BgPanel, "modulate", Color(0, 0, 0, 1), FADE_BG_TIME)
	
	file_folder.play("file_flip_open")
	
	## STATE
	is_open = true
	get_tree().paused = true
	
	## SETUP AVALIABLE ENTRIES
	for node: Node in [people_entries, places_entries, things_entries]:
		for child in node.get_children():
			node.remove_child(child)
			child.queue_free()
	
	# clear_entry_view()
	
	for entry: InfoLogEntryData in entry_data_nodes:
		## UNCOMMENT THESE LINES WHEN LOCKING SHOULD TAKE EFFECT
		# if not entry.is_unlocked():
		# 	continue
		
		var new_side_bar_btn: SideBarButton = SIDE_BAR_BUTTON_PREFAB.instantiate()
		new_side_bar_btn.button_entry_title = entry.title
		new_side_bar_btn.entry = entry
		new_side_bar_btn.text = entry.sidebar_title
		new_side_bar_btn.selected.connect(_on_entry_selected)
		
		match entry.category:
			"people":
				people_entries.add_child(new_side_bar_btn)
			"places":
				places_entries.add_child(new_side_bar_btn)
			"things":
				things_entries.add_child(new_side_bar_btn)
			_:
				pass

## Open to a specific page, if it exists...
func open_to_entry(entry_id: String) -> void:
	open()
	go_to_entry(entry_id)
## Category version...
func open_to_category(category_id: String) -> void:
	open()
	go_to_category(category_id)

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
	hide()

func _reset_tween() -> void:
	if bg_fade_tween != null:
		bg_fade_tween.kill()

#endregion

#region NAVIGATION

## GOTO LOGIC
## Go to a specific page or category...
func go_to_entry(entry_id: String) -> void:
	## WARNING:
	## These navigation code snippets are very scuffed.
	## Currently it works but it may need a refactor in the future...
	var selected_entry: InfoLogEntryData = null
	for entry: InfoLogEntryData in entry_data_nodes:
		if entry.id == entry_id:
			selected_entry = entry
			break
	
	if selected_entry == null:
		printerr("Attempted to go to an entry that doesn't exist, " + entry_id)
		return
	
	var node: Node
	match selected_entry.category:
		"people":
			people_btn.button_pressed = true
			people_btn.pressed.emit()
			node = people_entries
		"places":
			places_btn.button_pressed = true
			places_btn.pressed.emit()
			node = places_entries
		"things":
			things_btn.button_pressed = true
			things_btn.pressed.emit()
			node = things_entries
		_:
			pass
	
	for btn: SideBarButton in node.get_children():
		if btn.entry.id == entry_id:
			btn.button_pressed = true
			btn.pressed.emit()

func go_to_category(category_id: String) -> void:
	match category_id:
		"people":
			people_btn.button_pressed = true
			people_btn.pressed.emit()
		"places":
			places_btn.button_pressed = true
			places_btn.pressed.emit()
		"things":
			things_btn.button_pressed = true
			things_btn.pressed.emit()
		_:
			pass

#endregion

## ENTRIES SHOWING

func clear_entry_view() -> void:
	%Title.text = "Please select an entry to view."
	%Description.text = ""
	%JotNotes.text = ""
func _on_entry_selected(entry: InfoLogEntryData) -> void:
	clear_entry_view()
	%Title.text = entry.title
	%Description.text = entry.description
	for jot_note: InfoLogEntryData.JotNote in entry.jot_notes:
		## UNCOMMENT THESE LINES WHEN LOCKING SHOULD TAKE EFFECT
		# if not jot_note.is_unlocked():
		# 	continue
		
		%JotNotes.text += "- " + jot_note.content + "\n"

## BUTTON SIGNALS

func _on_people_btn_pressed():
	clear_entry_view()
	people_entries.show()
	places_entries.hide()
	things_entries.hide()
func _on_places_btn_pressed():
	clear_entry_view()
	people_entries.hide()
	places_entries.show()
	things_entries.hide()
func _on_things_btn_pressed():
	clear_entry_view()
	people_entries.hide()
	places_entries.hide()
	things_entries.show()
