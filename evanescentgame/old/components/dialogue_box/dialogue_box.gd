class_name DialogueBox
extends CanvasLayer

## CUSTOM DIALOGUE BOX building upon Dialogue Manager functionality

## A basic dialogue balloon for use with Dialogue Manager.

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

var _locale: String = TranslationServer.get_locale()

@onready var dialogue_box_control = %Balloon

@onready var hidden_anchor = $Hidden
@onready var visible_anchor = $Visible
@onready var next_label = %NextLabel
@onready var l_portrait = %LPortrait
@onready var r_portrait = %RPortrait

## The current line
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		next_label.hide()
		is_waiting_for_input = false
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()

		# The dialogue has finished so close the balloon
		if not next_dialogue_line:
			_hide_balloon()
			return

		# If the node isn't ready yet then none of the labels will be ready yet either
		if not is_node_ready():
			await ready

		dialogue_line = next_dialogue_line

		character_label.visible = not dialogue_line.character.is_empty()
		
		# Parsing Metadata
		var character_name = tr(dialogue_line.character, "dialogue")
		
		var end_metadata = character_name.find("~")
		var start_emotion = character_name.find("[")
		var end_emotion = character_name.find("]")
		var start_portrait_location = character_name.find("{")
		var end_portrait_location = character_name.find("}")
		
		# Get Portrait
		var portrait_path = "res://old/assets/portraits/"
		var portrait: Texture2D
		if (start_emotion == -1):
			portrait = load(portrait_path + "placeholder_neutral.png")
		else:
			var emotion = character_name.substr(start_emotion + 1, end_emotion - start_emotion - 1)
			
			if (["neutral", "excited", "embarrassed", "disappointed"].has(emotion)):
				portrait = load(portrait_path + "placeholder_" + emotion + ".png")
			else:
				print("WARNING: invalid emotion in dialogue: ", emotion)
		
		# Set Portrait on left or right
		l_portrait.texture = portrait
		
		# Set Character Name
		if (end_metadata == -1): 
			if (start_emotion == -1):
				true_character_name = character_name
			else:
				true_character_name = character_name.substr(0, start_emotion)
			
			character_name = true_character_name
			
			# Yucky if statements! Refactor this to be a singleton that keeps track of these things
			if (character_name == "Evan"):
				if (!Player.knows_name):
					character_name = "???"
			elif (character_name == "Lady Devil"):
				if (!Player.knows_devil_name):
					character_name = "???"
		else:
			true_character_name = character_name.substr(0, end_metadata)
			if (start_emotion == -1):
				character_name = character_name.substr(end_metadata + 1)
			else:
				character_name = character_name.substr(end_metadata + 1, start_emotion - end_metadata - 1)
			
		
		
		
		#print("True Character Name: ", true_character_name)
		#print("Shown Character Name: ", character_name)
		character_label.text = character_name
		
		dialogue_label.hide()
		dialogue_label.dialogue_line = dialogue_line

		responses_menu.hide()
		responses_menu.set_responses(dialogue_line.responses)

		# Show our balloon
		balloon.show()
		will_hide_balloon = false

		dialogue_label.show()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing

		# Wait for input
		next_label.show()
		if dialogue_line.responses.size() > 0:
			balloon.focus_mode = Control.FOCUS_NONE
			responses_menu.show()
		elif dialogue_line.time != "":
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()
	get:
		return dialogue_line

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

var true_character_name: String = ""

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

func _show_balloon() -> void:
	get_tree().create_tween().tween_property(dialogue_box_control, "position", visible_anchor.position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
func _hide_balloon() -> void:
	get_tree().create_tween().tween_property(dialogue_box_control, "position", hidden_anchor.position, 0.15).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.15).timeout
	queue_free()

func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states =  [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	
	dialogue_box_control.position = hidden_anchor.position
	
	# ANIMATE SHOW UP
	balloon.show()
	_show_balloon()
	
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			balloon.hide()
	)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)




#endregion

@onready var audio_manager: AudioManagerNode = $AudioManager

# Dialogue

func _on_dialogue_label_spoke(letter, letter_index, speed):
	if letter == " " or letter == ".":
		return
	
	match (true_character_name):
		"Evan":
			audio_manager.play_sfx("Evan", false, true, 0, 0, 0.9, 1.1)
		"Lady Devil":
			audio_manager.play_sfx("LadyDevil", false, true, 0, 0, 0.9, 1.1)
		"Ghost":
			audio_manager.play_sfx("Ghost", false, true, 0, 0, 0.9, 1.1)
		_:
			pass
			#print("Invalid character set: ", true_character_name) # suppress a billion print statements
	






