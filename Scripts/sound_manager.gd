extends AudioStreamPlayer2D
	
func play_sound(sound: AudioStream):
	stream = sound
	play()
	
