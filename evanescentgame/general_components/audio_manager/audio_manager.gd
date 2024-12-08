class_name AudioManagerNode
extends Node


func play_sfx(sfx_name: String, is_randomize_volume: bool = false, is_randomize_pitch: bool = false, volume_min: float = 0, volume_max: float = 0, pitch_min: float = 0, pitch_max: float = 0):
	var sfx = get_node(sfx_name) as AudioStreamPlayer
	
	if (not sfx):
		return
	
	if is_randomize_volume:
		randomize_volume(sfx, volume_min, volume_max)
	if is_randomize_pitch:
		randomize_pitch(sfx, pitch_min, pitch_max)
	
	sfx.play()

func randomize_volume(sfx: AudioStreamPlayer, volume_min: float, volume_max: float):
	var volume = randf_range(volume_min, volume_max)
	sfx.volume_db = volume

func randomize_pitch(sfx: AudioStreamPlayer, pitch_min: float, pitch_max: float):
	var pitch = randf_range(pitch_min, pitch_max)
	sfx.pitch_scale = pitch
