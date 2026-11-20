extends Node2D

const Nozzle = preload("res://FuelNozzle.gd")
const Pump = preload("res://FuelPump.gd")
var nozzle := Nozzle.new()
var pump := Pump.new()
var origin_hull := Vector2.ZERO
var socket := Vector2.ZERO
var deployed := 0.0
var show_port := false
var mark_port := false
var crank := 0.0
var previous_length := 0.0
var travel := 0.0
var running := false
var colour := Color("79d6ca")
var line := PackedVector2Array()

func _ready() -> void:
	z_index = 1
	add_child(pump)
	pump.z_index = 1
	add_child(nozzle)
	nozzle.z_index = 1

func arm(hull: Vector2, docked: bool, delta: float) -> void:
	origin_hull = hull
	deployed = move_toward(deployed,1.0 if docked else 0.0,delta*2.4)
	socket = hull + Vector2(-12.0,72.0)*smoothstep(0,1,deployed)
	show_port = deployed > 0.01

func update_hose(grip: Vector2, angle: float, held: bool, coupled: bool, show_target: bool, volume: float, flow: float, tint: Color, delta: float) -> void:
	nozzle.position = grip
	nozzle.rotation = angle
	nozzle.z_index = 3 if held else 1
	mark_port = show_target
	running = flow > 0.0
	colour = tint
	var start := pump.position + Pump.REEL + Vector2(9.0,10.0)
	var end := grip + Vector2(-15,-2).rotated(angle)
	var length_now := start.distance_to(end)
	crank += (length_now-previous_length)/13.0
	previous_length = length_now
	travel = fposmod(travel + flow*0.035*delta,1.0)
	pump.update_readings(volume,flow,crank,coupled,delta)
	# Hose rests on the deck and lifts only near the operator or the locked coupling.
	var midpoint := Vector2(lerpf(start.x,end.x,0.48),466.0 + minf(7.0,length_now*0.022))
	var reach := end.x-start.x
	line.resize(33)
	for i in range(17):
		var t := i/16.0
		line[i] = start.bezier_interpolate(start+Vector2(12,13),midpoint-Vector2(reach*0.16,0),midpoint,t)
		line[16+i] = midpoint.bezier_interpolate(midpoint+Vector2(reach*0.19,0),end+Vector2(-cos(angle)*14,13),end,t)
	queue_redraw()

func _draw() -> void:
	if show_port:
		draw_line(origin_hull,socket,Color("152a32"),12,true)
		draw_line(origin_hull,socket,Color("829593"),7,true)
		draw_line(origin_hull.lerp(socket,0.38),socket,Color("bac4b6"),3,true)
		draw_circle(origin_hull,6,Color("45616a"))
		draw_rect(Rect2(socket-Vector2(10,7),Vector2(20,8)),Color("324d59"))
		draw_line(socket+Vector2(-8,1),socket+Vector2(8,1),Color("e2ae68"),3,true)
		if mark_port:
			draw_arc(socket,15,0.15,PI-0.15,16,Color("ffc87a"),2,true)
			draw_string(ThemeDB.fallback_font,socket+Vector2(17,1),"BOCAL",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffdc97"))
	if line.size() < 2:
		return
	draw_polyline(line,Color("101c25"),8,true)
	draw_polyline(line,Color("526368"),5,true)
	draw_polyline(line,Color("263940"),3,true)
	# Two compression bands, plus moving indicators only while fuel is flowing.
	for idx in [2,29]:
		draw_line(line[idx],line[idx+1],Color("b39569"),5,true)
	if running:
		for i in range(5):
			var at := fposmod(travel + i/5.0,1.0)*31
			var n := int(at)
			var a := line[n].lerp(line[n+1],at-n)
			draw_line(a,a.direction_to(line[n+2])*4.0+a,colour.lightened(0.2),2.6,true)
