extends Node

const OVERWORLD_PATH = "res://scenes/overworld/overworld.tscn"
const UNDERWORLD_PATH = "res://scenes/underworld/underworld.tscn"
const UNDERWORLD_INTRODUCTION_PATH = "res://scenes/underworld/underworld_introduction/underworld_introduction.tscn"
const MAIN_MENU_PATH = "res://ui/main_menu/main_menu.tscn"

@onready var loading_screen_scene: PackedScene = preload("./loading_screen.tscn")

var loading_screen_instance: Control
var is_loading: bool
var scene_to_load_path: String

func load_overworld():
	load_scene(OVERWORLD_PATH)

func load_underworld():
	load_scene(UNDERWORLD_PATH)

func load_underworld_introduction():
	load_scene(UNDERWORLD_INTRODUCTION_PATH)

func load_main_menu():
	load_scene(MAIN_MENU_PATH)

func load_scene(scene_path: String):
	# Instantiate loading screen, add to SceneTree
	loading_screen_instance = loading_screen_scene.instantiate()
	get_tree().root.call_deferred("add_child", loading_screen_instance)
	
	# The ResourceLoader class can load scenes and store them in a cache, therefore 
	# removing the need to load the scene again since you can just retrieve it from the cache
	# This loads the scene asyncronously and stores it in the cache IF it is not already in the cache
	if (not ResourceLoader.has_cached(scene_path)):
		ResourceLoader.load_threaded_request(scene_path)
	
	# Free the current scene
	var current_scene = get_tree().current_scene
	get_tree().current_scene = null
	current_scene.queue_free()
	
	# Begin loading next scene
	is_loading = true
	scene_to_load_path = scene_path

func _process(delta):
	if (not is_loading):
		return
	
	
	var status = ResourceLoader.load_threaded_get_status(scene_to_load_path, [])
	if (status == ResourceLoader.THREAD_LOAD_LOADED):
		# Load scene from cache
		var next_scene: PackedScene = ResourceLoader.load_threaded_get(scene_to_load_path)
		get_tree().change_scene_to_packed(next_scene)
		is_loading = false
		loading_screen_instance.queue_free()
		print("SceneLoader loaded: ", scene_to_load_path, " ! YAY :D")
	elif (status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE):
		print("SceneLoader failed to load: ", scene_to_load_path)
