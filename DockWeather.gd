extends Node2D

var sky := ColorRect.new()
var material_sky := ShaderMaterial.new()
var breeze := AudioStreamPlayer.new()
var motor := AudioStreamPlayer.new()
var seal := AudioStreamPlayer.new()
var wind_filter := AudioEffectLowPassFilter.new()
var wind_bus := ""
var last_closure := 0.0
var age := 0.0
var storm_door := preload("res://StormShutter.gd").new()
var shutter := 0.0:
	set(value):
		shutter = clampf(value, 0.0, 1.0)
		storm_door.set_closure(shutter)
var level := 0.0

func _ready() -> void:
	z_index = 4
	# The landscape sits behind the structure; grains pass in front of the dock.
	sky.z_as_relative = false
	sky.z_index = -5
	sky.position = Vector2(0,98)
	sky.size = Vector2(1280,382)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	material_sky.shader = preload("res://MartianFront.gdshader")
	sky.material = material_sky
	add_child(sky)
	add_child(storm_door)
	storm_door.set_closure(shutter)
	breeze.stream = AudioStreamWAV.load_from_file("res://Ventania.wav")
	if breeze.stream:
		breeze.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		breeze.stream.loop_end = int(breeze.stream.get_length()*breeze.stream.mix_rate)
	breeze.volume_db = -60
	# Give only the exterior wind an acoustic filter.
	wind_bus = "DockWind_%s" % get_instance_id()
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, wind_bus)
	AudioServer.add_bus_effect(index, wind_filter)
	breeze.bus = wind_bus
	add_child(breeze)
	motor.stream = AudioStreamWAV.load_from_file("res://ShutterMotor.wav")
	if motor.stream:
		motor.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		motor.stream.loop_end = int(round(motor.stream.get_length() * motor.stream.mix_rate))
	seal.stream = AudioStreamWAV.load_from_file("res://ShutterSeal.wav")
	seal.volume_db = -9.0
	add_child(motor)
	add_child(seal)

func _exit_tree() -> void:
	var index := AudioServer.get_bus_index(wind_bus)
	if index > 0:
		AudioServer.remove_bus(index)

func stop_audio() -> void:
	breeze.stop()
	motor.stop()
	seal.stop()

func update_door_audio(delta: float, muted: bool) -> void:
	var speed := clampf(absf(shutter - last_closure) / maxf(delta, 0.0001), 0.0, 1.0)
	if not muted and shutter > 0.0 and shutter < 1.0 and speed > 0.0:
		motor.pitch_scale = 0.76 + speed * 0.38
		motor.volume_db = -21.0 + speed * 8.0
		if not motor.playing:
			motor.play()
	else:
		motor.stop()
	if not muted and shutter >= 1.0 and last_closure > 0.0 and last_closure < 1.0:
		seal.play()
	last_closure = shutter
	wind_filter.cutoff_hz = 12000.0 * pow(0.055, shutter)


func advance(delta: float, storm_age: float, storm: bool, muted: bool) -> void:
	age += delta
	update_door_audio(delta, muted)
	var target := 0.0
	if storm:
		var arrival := smoothstep(0.0,5.0,storm_age)
		var clearing := 1.0-smoothstep(17.0,28.0,storm_age)
		target = arrival*clearing*(0.88+0.12*sin(storm_age*1.6))
	level = move_toward(level,target,delta*0.55)
	material_sky.set_shader_parameter("age",age)
	material_sky.set_shader_parameter("strength",level)
	if level > 0.015 and not muted:
		breeze.volume_db = linear_to_db(0.48*level) - 13.0 * shutter
		if not breeze.playing:
			breeze.play()
	elif breeze.playing:
		breeze.stop()
	queue_redraw()

func _draw() -> void:
	# A fabric windsock responds to the same gust that drives the grains.
	var anchor := Vector2(420,396)
	draw_line(anchor,anchor+Vector2(0,40),Color("879395"),2,true)
	var top := anchor
	var bottom := anchor+Vector2(0,8)
	for j in range(5):
		var f := float(j+1)/5.0
		var center := anchor+Vector2(f*(8.0+29.0*level),4.0+f*(1.0-level)*24.0+f*sin(age*6.0-j*0.7)*(0.5+level*3.0))
		var dy := Vector2(0,4.0-f*2.2)
		draw_colored_polygon(PackedVector2Array([top,center-dy,center+dy,bottom]),Color("d97f4f") if j%2==0 else Color("dcceaa"))
		top = center-dy
		bottom = center+dy
	if level < 0.02 or shutter >= 1.0:
		return
	# Different grain speeds and sizes give depth, with a denser layer near the deck.
	for i in range(145):
		var layer := fposmod(i*0.618,1.0)
		var speed := (74.0+layer*250.0)*(1.0+0.16*sin(age*1.45 + i*0.13))
		var x := fposmod(i*137.31+age*(74.0+layer*250.0)+15.0*sin(age*1.45+i),1295.0)-7.0
		var y := 182.0+fposmod(i*59.7,279.0) + 4.8*sin(x*0.013+age*1.6+i)
		if i % 3 == 0:
			y = 447.0 + 13.0*sin(age*1.1 + x*0.014 + i)
		if shutter > 0.0 and y < storm_door.position.y + storm_door.size.y * shutter:
			continue
		var tint := Color(0.94,0.74,0.50,level*(0.10+0.42*layer))
		draw_line(Vector2(x,y),Vector2(x+speed*0.024,y-1.0-layer*1.7),tint,0.7+layer*0.85,true)
