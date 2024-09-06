extends Node

var sample_hz = 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.
#var pulse_hz = 440.0
var pulse_hz_1 = 440.0
var pulse_hz_2 = 440.0
var pulse_hz_3 = 440.0
var phase_1 = 0.0
var phase_2 = 0.0
var phase_3 = 0.0

var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().

func _fill_buffer():
	var playbacks_active = 3
	var increment_1 = pulse_hz_1 / sample_hz
	var increment_2 = pulse_hz_2 / sample_hz
	var increment_3 = pulse_hz_3 / sample_hz

	var to_fill = playback.get_frames_available()
	while to_fill > (playbacks_active - 1): # or > 0  or > 2 if 3 frames go at once bc 3 sounds
		#if sound_1_active:
		# sine
		#playback.push_frame(Vector2.ONE * sin(phase_1 * TAU)) # Audio frames are stereo.
		phase_1 = fmod(phase_1 + increment_1, 1.0)
		# square
		#playback.push_frame(Vector2.ONE * sign(sin(phase_2 * TAU)))
		#playback.push_frame(Vector2.ONE * sin(phase_2 * TAU))
		phase_2 = fmod(phase_2 + increment_2, 1.0)
		# triangle
		#playback.push_frame(Vector2.ONE * 2 * abs(phase - floor(phase + 0.5)))
		# sawtooth
		var total_phase = sin(phase_1 * TAU) + sign(sin(phase_2 * TAU)) + phase_3
		playback.push_frame(Vector2.ONE * total_phase)
		#playback.push_frame(Vector2.ONE * sin(phase_3 * TAU))
		phase_3 = fmod(phase_3 + increment_3, 1.0)
		
		to_fill -= playbacks_active # 0 or -= 3 bc 3 sounds played in every frame


func _process(_delta):
	_fill_buffer()


func _ready():
	# Setting mix rate is only possible before play().
	$Player.stream.mix_rate = sample_hz
	$Player.play()
	playback = $Player.get_stream_playback()
	# `_fill_buffer` must be called *after* setting `playback`,
	# as `fill_buffer` uses the `playback` member variable.
	_fill_buffer()


func _on_frequency_h_slider_1_value_changed(value):
	%FrequencyLabel1.text = "%d Hz" % value
	pulse_hz_1 = value
	
func _on_frequency_h_slider_2_value_changed(value):
	%FrequencyLabel2.text = "%d Hz" % value
	pulse_hz_2 = value
	
func _on_frequency_h_slider_3_value_changed_3(value):
	%FrequencyLabel3.text = "%d Hz" % value
	pulse_hz_3 = value


func _on_volume_h_slider_value_changed(value):
	# Use `linear_to_db()` to get a volume slider that matches perceptual human hearing.
	%VolumeLabel.text = "%.2f dB" % linear_to_db(value)
	$Player.volume_db = linear_to_db(value)
