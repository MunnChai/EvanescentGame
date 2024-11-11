extends Node

@onready var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_stream_player.bus = "Music"
	call_deferred("add_child", audio_stream_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_track(audio_path: String):
	var audio = load(audio_path)
	audio_stream_player.stream = audio
	audio_stream_player.playing = true

func transition_to_track(audio_path: String):
	pass
