extends Node2D

# Local coordinates use the machine's contact point with the deck as origin.
const REEL := Vector2(24,-20)
const HOLSTER := Vector2(-37,-26)
var delivered := 0.0
var pressure := 0.0
var rotation_phase := 0.0
var running := false
var latched := false

func update_readings(amount: float, flow: float, reel_angle: float, coupled: bool, delta: float) -> void:
	delivered = amount
	running = flow > 0.0
	pressure = move_toward(pressure,clampf(flow/100.0,0.0,1.0),delta*1.4)
	rotation_phase = reel_angle
	latched = coupled
	queue_redraw()

func _draw() -> void:
	var ink := Color("162a34")
	var steel := Color("718a8c")
	var brass := Color("da9b55")
	# Chapa de ancoragem e borda frontal apoiadas sobre a sombra do piso.
	var base := PackedVector2Array([Vector2(-51,-1),Vector2(47,-1),Vector2(55,6),Vector2(-57,6)])
	draw_colored_polygon(base,Color("647578"))
	draw_rect(Rect2(-57,6,112,4),Color("253c45"))
	draw_line(Vector2(-56,6),Vector2(54,6),Color("8a9890"),1,true)
	for bolt in [-47,44]:
		draw_circle(Vector2(bolt,4),3,ink)
		draw_circle(Vector2(bolt,3),1.7,Color("b2b5a3"))
		draw_line(Vector2(bolt-1,3),Vector2(bolt+1,3),ink,1)
	draw_rect(Rect2(-48,-3,96,5),ink)
	var hull := PackedVector2Array([Vector2(-41,-4),Vector2(-41,-47),Vector2(-33,-57),Vector2(29,-57),Vector2(42,-45),Vector2(42,-4)])
	draw_colored_polygon(hull,Color("335260"))
	draw_polyline(hull + PackedVector2Array([hull[0]]),steel,1.6,true)
	draw_line(Vector2(-32,-53),Vector2(27,-53),Color("abc0b4"),1.5,true)
	draw_rect(Rect2(-33,-47,41,16),ink)
	draw_string(ThemeDB.fallback_font,Vector2(-32,-35),"%03d UF" % int(delivered),HORIZONTAL_ALIGNMENT_CENTER,38,9,Color("a7e7d4"))
	draw_rect(Rect2(-29,-25,22,19),Color("263f4a"))
	for i in range(4):
		draw_line(Vector2(-26,-22+i*4),Vector2(-11,-22+i*4),steel,1.3)
	# Pressure gauge responds to effective flow, including filter restrictions.
	var dial := Vector2(23,-45)
	draw_circle(dial,9,ink)
	draw_arc(dial,7.3,2.5,6.8,20,Color("9eafaa"),1.2,true)
	draw_line(dial,dial+Vector2.from_angle(2.55+pressure*4.1)*6.2,brass,1.7,true)
	draw_circle(dial,1.6,Color("d4d8c8"))
	draw_circle(REEL,17,ink)
	draw_circle(REEL,14,Color("3c5861"))
	for i in range(3):
		draw_arc(REEL,7.0+2.4*i,0,TAU,36,Color("1a2a31"),1.6,true)
	for i in range(3):
		var ray := Vector2.from_angle(rotation_phase+TAU*i/3.0)
		draw_line(REEL+ray*3.0,REEL+ray*13.0,brass,2.1,true)
	draw_circle(REEL,3.6,Color("bdc7b7"))
	draw_rect(Rect2(-42,-32,8,13),ink)
	draw_line(Vector2(-43,-30),Vector2(-43,-21),brass,2)
	var lamp := Color("f1b663") if not latched else Color("8be8bd")
	draw_rect(Rect2(-4,-25,5,12),ink)
	draw_rect(Rect2(-3,-24,3,10),lamp)
	for x in [-35,35]:
		draw_circle(Vector2(x,-5),1.5,Color("c0c6b4"))
	draw_string(ThemeDB.fallback_font,Vector2(-50,26),"BOMBA  01",HORIZONTAL_ALIGNMENT_CENTER,100,12,Color("8de1ce"))
