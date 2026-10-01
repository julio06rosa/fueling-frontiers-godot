extends Node

var music_playback: AudioStreamGeneratorPlayback
var pump_playback: AudioStreamGeneratorPlayback
var sfx_playback: AudioStreamGeneratorPlayback

var music_player: AudioStreamPlayer
var pump_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var music_time: float = 0.0
var pump_time: float = 0.0

var sfx_queue: Array = []
var sfx_time: float = 0.0
var sfx_duration: float = 0.0
var sfx_freq: float = 440.0
var sfx_type: String = "sine"

var is_pump_active: bool = false
var pump_pitch: float = 100.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set up music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	var music_gen = AudioStreamGenerator.new()
	music_gen.mix_rate = 22050
	music_gen.buffer_length = 0.2
	music_player.stream = music_gen
	music_player.volume_db = -12.0
	
	# Set up pump player
	pump_player = AudioStreamPlayer.new()
	add_child(pump_player)
	var pump_gen = AudioStreamGenerator.new()
	pump_gen.mix_rate = 22050
	pump_gen.buffer_length = 0.2
	pump_player.stream = pump_gen
	pump_player.volume_db = -8.0

	# Set up SFX player
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	var sfx_gen = AudioStreamGenerator.new()
	sfx_gen.mix_rate = 22050
	sfx_gen.buffer_length = 0.2
	sfx_player.stream = sfx_gen
	sfx_player.volume_db = -3.0
	
	music_player.play()
	music_playback = music_player.get_stream_playback()
	
	pump_player.play()
	pump_playback = pump_player.get_stream_playback()
	
	sfx_player.play()
	sfx_playback = sfx_player.get_stream_playback()

func _process(delta):
	fill_music_buffer()
	fill_pump_buffer()
	fill_sfx_buffer()

func fill_music_buffer():
	if music_playback == null:
		return
	var frames_to_fill = music_playback.get_frames_available()
	while frames_to_fill > 0:
		# Ambient music drone: sum of D2, A2, D3 slowly modulating
		var freq1 = 73.42
		var freq2 = 110.0
		var freq3 = 146.83
		
		var f1 = freq1 + sin(music_time * 0.5) * 0.5
		var f2 = freq2 + cos(music_time * 0.3) * 0.8
		var f3 = freq3 + sin(music_time * 0.2 + 1.0) * 1.2
		
		var val = sin(music_time * f1 * 2.0 * PI) * 0.4
		val += sin(music_time * f2 * 2.0 * PI) * 0.3
		val += sin(music_time * f3 * 2.0 * PI) * 0.3
		
		val = clamp(val, -1.0, 1.0)
		
		music_playback.push_frame(Vector2(val, val))
		music_time += 1.0 / 22050.0
		frames_to_fill -= 1

func fill_pump_buffer():
	if pump_playback == null:
		return
	var frames_to_fill = pump_playback.get_frames_available()
	while frames_to_fill > 0:
		var val = 0.0
		if is_pump_active:
			# Motor hum: square wave + noise
			var cycle = sin(pump_time * pump_pitch * 2.0 * PI)
			var w = 1.0 if cycle > 0.0 else -1.0
			var noise = randf_range(-1.0, 1.0) * 0.2
			val = (w * 0.5 + noise) * 0.3
		
		pump_playback.push_frame(Vector2(val, val))
		pump_time += 1.0 / 22050.0
		frames_to_fill -= 1

func fill_sfx_buffer():
	if sfx_playback == null:
		return
	var frames_to_fill = sfx_playback.get_frames_available()
	while frames_to_fill > 0:
		var val = 0.0
		if sfx_duration > 0.0:
			if sfx_type == "sine":
				val = sin(sfx_time * sfx_freq * 2.0 * PI)
				val *= (sfx_duration - sfx_time) / sfx_duration
			elif sfx_type == "noise":
				val = randf_range(-1.0, 1.0) * 0.5
				val *= (sfx_duration - sfx_time) / sfx_duration
			elif sfx_type == "click":
				val = sin(sfx_time * sfx_freq * 2.0 * PI)
				if sfx_time > 0.01:
					val = 0.0
			elif sfx_type == "chime":
				var f1 = sfx_freq
				var f2 = sfx_freq * 1.25 # major third
				var f3 = sfx_freq * 1.5  # perfect fifth
				var f4 = sfx_freq * 2.0  # octave
				val = sin(sfx_time * f1 * 2.0 * PI) * 0.3
				val += sin(sfx_time * f2 * 2.0 * PI) * 0.25
				val += sin(sfx_time * f3 * 2.0 * PI) * 0.2
				val += sin(sfx_time * f4 * 2.0 * PI) * 0.15
				val *= (sfx_duration - sfx_time) / sfx_duration
			elif sfx_type == "alarm":
				var wobble = sin(sfx_time * 8.0 * PI) * 100.0
				val = sin(sfx_time * (sfx_freq + wobble) * 2.0 * PI)
				val *= (sfx_duration - sfx_time) / sfx_duration
				
			sfx_time += 1.0 / 22050.0
			if sfx_time >= sfx_duration:
				sfx_duration = 0.0
				if sfx_queue.size() > 0:
					var next = sfx_queue.pop_front()
					play_sfx_now(next.type, next.freq, next.duration)
		
		sfx_playback.push_frame(Vector2(val, val))
		frames_to_fill -= 1

func play_sfx_now(type: String, freq: float, duration: float):
	sfx_type = type
	sfx_freq = freq
	sfx_duration = duration
	sfx_time = 0.0

func queue_sfx(type: String, freq: float, duration: float):
	if sfx_duration <= 0.0:
		play_sfx_now(type, freq, duration)
	else:
		sfx_queue.append({"type": type, "freq": freq, "duration": duration})

func play_click():
	queue_sfx("click", 1200.0, 0.05)

func play_step():
	queue_sfx("sine", 80.0, 0.1)

func play_success():
	queue_sfx("chime", 587.33, 0.8)

func play_failure():
	queue_sfx("alarm", 150.0, 1.0)

func play_landing():
	queue_sfx("noise", 100.0, 1.5)

func set_pump_active(active: bool):
	is_pump_active = active
