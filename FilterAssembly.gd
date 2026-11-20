extends Node2D

# Local geometry is shared by the dock equipment and its inspection view.
const CENTRES := [-35.0, -12.0, 11.0]
var deposits := Vector3.ZERO
var fault := false
var detent := 0
var clock := 0.0
var burst := 0.0
var burst_x := 0.0

func update_view(grit: Vector3, damaged: bool, collar: int, elapsed: float, burst_left: float, jet_x: float) -> void:
	deposits = grit
	fault = damaged
	detent = collar
	clock = elapsed
	burst = burst_left
	burst_x = jet_x
	queue_redraw()

func _draw() -> void:
	var steel := Color("435963")
	var rim := Color("82989a")
	var black := Color("192a36")
	# Feet, inlet pipe, bolted cast housing.
	for x in [-47, 41]:
		draw_rect(Rect2(x,-1,9,29),black)
		draw_rect(Rect2(x-4,24,17,4),steel)
	draw_rect(Rect2(-71,0,20,9),steel)
	draw_rect(Rect2(-60,-4,5,18),rim)
	draw_rect(Rect2(51,0,22,9),steel)
	draw_rect(Rect2(62,-3,5,15),rim)
	var housing := PackedVector2Array([Vector2(-53,-19),Vector2(-46,-25),Vector2(51,-25),Vector2(56,-20),Vector2(56,17),Vector2(51,22),Vector2(-48,22),Vector2(-53,16)])
	draw_colored_polygon(housing,Color("314653"))
	draw_polyline(housing + PackedVector2Array([housing[0]]),rim,1.3,true)
	draw_rect(Rect2(-47,-17,70,34), black)
	for i in range(3):
		draw_cartridge(i)
	# Pressure dial and locking collar. The witness marks coincide at detent zero.
	var c := Vector2(40,-4)
	draw_circle(c,13.5,black)
	draw_arc(c,11.8,0,TAU,36,steel,2.6,true)
	draw_arc(c,9.3,PI,TAU,24,Color("80b7ae"),1.1,true)
	var angle := deg_to_rad(-92.0 + (float(detent) * 18.0 if fault else 0.0))
	var needle := deg_to_rad(-80.0 + (sin(clock*8.0)*58.0 if fault else deposits.length()*31.0))
	draw_line(c,c+Vector2.from_angle(needle)*7.5,Color("ffdfaf"),1.5,true)
	draw_circle(c,1.9,rim)
	draw_line(c+Vector2.from_angle(angle)*10,c+Vector2.from_angle(angle)*14,Color("ffb44e"),2.3,true)
	draw_line(c+Vector2(0,-16),c+Vector2(0,-20),Color("d4f1ef"),1.8)
	var lamp := Color("7addb3")
	if deposits.length_squared() > 0.01:
		lamp = Color("f1b353")
	if fault:
		lamp = Color("f77a55").lerp(Color("9e483c"),0.5+0.5*sin(clock*5))
	draw_rect(Rect2(28,13,21,2.8),lamp)
	for x in [-48,51]:
		for y in [-19,16]:
			draw_circle(Vector2(x,y),1.5,Color("9da6a0"))
	if fault:
		draw_leak()
	if burst > 0.0:
		var age := 1.0-burst
		for i in range(15):
			var a := Vector2(burst_x,-7) + Vector2(sin(i*7.7)*age*16.0 + age*15.0, -age*(13.0+fmod(i*7.0,20.0)))
			draw_circle(a,1.0+age*2.1,Color(0.92,0.67,0.40,burst*0.6))

func draw_cartridge(i: int) -> void:
	var x: float = CENTRES[i]
	var load_amount := deposits[i]
	var frame := Rect2(x-10,-15,20,30)
	draw_rect(frame,Color("596e70"))
	draw_rect(frame.grow(-1.4),Color("273b47"))
	for j in range(7):
		var y := -11.0+j*3.6
		draw_line(Vector2(x-7.5,y),Vector2(x+7.5,y),Color("91a8a9"),1.3,true)
		draw_line(Vector2(x-6.5,y+1),Vector2(x+7.5,y+1),Color("485f68"),0.7)
	if load_amount <= 0.0:
		return
	# Sediment rests on the pleats and packs into a continuous bed at the bottom.
	# The irregular upper edge and layers of fine grain stay legible in the close-up.
	var crust := PackedVector2Array()
	for k in range(15):
		var xx := x - 8.2 + k*1.17
		var top := 13.0-load_amount*(18.0+5.0*sin(k*0.48+i*1.8)+1.2*sin(k*1.82+i))
		crust.append(Vector2(xx,top))
	crust.append(Vector2(x+8.2,14))
	crust.append(Vector2(x-8.2,14))
	draw_colored_polygon(crust,Color("ab7352"))
	for j in range(7):
		var yy := -10.4+j*3.6
		draw_line(Vector2(x-7.0,yy),Vector2(x-7.0+load_amount*(7.0+5.0*sin(i+j*0.8)),yy-0.3),Color("ba9773"),0.95,true)
	for j in range(143):
		var xx := fposmod(j*0.6180339+i*0.23,1.0)*15.5
		var yy := -14.0+fposmod(j*0.4142135+j*j*0.000291+i*0.14,1.0)*27.5
		var edge := 13.0-load_amount*(18.0+5.0*sin(xx*0.41+i*1.8))
		if yy < edge-1.0:
			continue
		var tone := Color("7e543e").lerp(Color("d9b28c"),fposmod(j*0.317,1.0))
		draw_line(Vector2(x-7.7+xx,yy),Vector2(x-7.2+xx,yy-0.1),tone,0.7,true)
	draw_line(Vector2(x-8.3,13.4),Vector2(x+8.3,13.4),Color("d8ad85"),1.1,true)

func draw_leak() -> void:
	for i in range(7):
		var phase := fposmod(clock*1.7+i/7.0,1.0)
		var c := Vector2(61,-1) + Vector2(phase*17, -phase*24+sin(i+clock*3.5)*phase*3)
		draw_circle(c,1.1+phase*3.8,Color(0.72,0.86,0.86,(1.0-phase)*0.40))
