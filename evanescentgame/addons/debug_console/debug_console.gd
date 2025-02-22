@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("DebugConsole", get_plugin_path() + "/debug_console_global.gd")

func _exit_tree():
	remove_autoload_singleton("DebugConsole")

func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir()
