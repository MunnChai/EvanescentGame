class_name DebugConsoleConfig
extends Resource

## Name of the studio to be tracked in the log
@export var studio_name : String = "Untitled Studio"



@export_category("Logging")
## Prefix of the log file, of format [code]PREFIX_<Time>_<Iteration>.txt[/code]
@export var log_file_name_prefix : String = "debug_log"

## Directory path for log files to be written to
## (See Godot file path documentation for how to write)
@export_dir var default_logs_directory_path : String = "res://debug_logs"

## Whether or not log entries should also be printed to the Godot Output tab
@export var print_to_godot_console : bool = false

## Whether or not BBCode should be stripped from entries in the dump file
@export var strip_bbcode : bool = true

## Maximum number of entries before log starts discarding old entries
@export_range(1, 100000, 0.01, "exp")
var max_entries_before_cutoff : int = 1000



@export_category("Console")

## What font size is the text in the console displayed as?
@export_range(1, 256)
var font_size : int = 24

## Whether or not the main game tree should be paused when the console is open
## (Possibly helps prevent input interference from keys?)
@export var pause_tree_when_open : bool = false
