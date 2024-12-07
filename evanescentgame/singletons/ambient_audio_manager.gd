extends Node

@onready var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()

const AUDIO_FADE_DURATION: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_stream_player.bus = "Music"
	call_deferred("add_child", audio_stream_player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_volume(volume: float):
	audio_stream_player.volume_db = volume

func set_pitch(pitch_scale: float):
	audio_stream_player.pitch_scale = pitch_scale

func play_track(audio: AudioStream):
	audio_stream_player.stream = audio
	audio_stream_player.playing = true

func transition_to_track(audio: AudioStream):
	if (audio == audio_stream_player.stream):
		return
	
	var tween: Tween = get_tree().create_tween()
	
	tween.set_parallel(false)
	tween.tween_method(set_volume, 0, -50, AUDIO_FADE_DURATION)
	tween.tween_method(set_volume, -50, 0, AUDIO_FADE_DURATION)
	await get_tree().create_timer(AUDIO_FADE_DURATION).timeout
	play_track(audio)





