extends Node2D

# Arte vetorial local: não depende de texturas externas ou downloads.
var clock: float = 0.0
var ship_class := ""
var origin: String = "Terra"
var moving: bool = false
var pumping: bool = false
var service_light := false
var elite: bool = false
var fill: float = 0.0
var accent: Color = Color("63dce8")

const SETTLE_TIME := 0.58
const FOOT_Y := 94.0
var touchdown_age := SETTLE_TIME
var gear_extension := 0.0
var compression := 0.0
var altitude := 0.0
var dust_strength := 0.0
var dust_clock := 0.0

func reset_landing() -> void:
	touchdown_age = SETTLE_TIME
	compression = 0.0
	dust_strength = 0.0
	gear_extension = 0.0
	dust_clock = 0.0

func update_landing(delta: float, base: Vector2, pad: Vector2, approaching: bool, departing: bool) -> void:
	var gap := absf(base.x - pad.x)
	var flight := smoothstep(5.0, 145.0, gap) if approaching or departing else 0.0
	altitude = flight * 32.0
	gear_extension = 1.0 - smoothstep(36.0, 195.0, gap)
	touchdown_age = minf(touchdown_age + delta, SETTLE_TIME)
	var phase := touchdown_age / SETTLE_TIME
	compression = 8.0 * sin(PI * phase) * pow(1.0 - phase, 2.0)
	dust_strength = (1.0 - flight) if approaching else pow(1.0 - phase, 1.5)
	dust_clock += delta
	position = base + Vector2(0, compression - altitude)
	rotation = sin(clock * 1.5) * 0.012 * flight

func draw_landing_gear() -> void:
	var floor_y := FOOT_Y - compression + altitude
	# The downwash flows out across the deck on both sides of the two skids.
	if dust_strength > 0.01:
		for side in [-1.0, 1.0]:
			for grain in range(11):
				var travel := fposmod(dust_clock * 1.7 + grain * 0.618, 1.0)
				var spread: float = side * (33.0 + 100.0 * travel)
				var lift := (4.0 + (grain % 4) * 2) * sin(PI * travel)
				var tip := Vector2(spread, floor_y - lift + grain % 3)
				var tint := Color(0.79, 0.63, 0.46, dust_strength * sin(PI * travel) * 0.60)
				draw_line(tip, tip + Vector2(side * (3 + grain % 6), -1), tint, 1.8, true)
	if gear_extension <= 0.0:
		return
	for x in [-43.0, 42.0]:
		var top := Vector2(x, 17)
		var foot := Vector2(x - 9.0, lerpf(20.0, FOOT_Y, gear_extension) - compression)
		var sleeve := top.lerp(foot, 0.58)
		draw_line(top, foot, Color("14232c"), 7.0, true)
		draw_line(top, sleeve, Color("637780"), 5.0, true)
		draw_line(sleeve, foot, Color("b2bbb7"), 3.0, true)
		draw_line(foot + Vector2(-8, 0), foot + Vector2(8, 0), Color("34434b"), 5.0, true)

func _process(delta):
	clock += delta
	queue_redraw()

func plate(points: Array, color: Color):
	var polygon := PackedVector2Array(points)
	draw_colored_polygon(polygon, color)
	polygon.append(polygon[0])
	draw_polyline(polygon, Color("111d2e"), 2.0, true)

func lamp(point: Vector2, color: Color, radius: float = 3.0):
	draw_circle(point, radius * 3.5, Color(color, 0.06))
	draw_circle(point, radius * 2.0, Color(color, 0.14))
	draw_circle(point, radius, color)
	draw_circle(point, radius * 0.4, Color("e9ffff"))

func _draw():
	var hull := Color("a9bacb")
	accent = Color("63dce8")
	var wing: float = 70.0
	if origin == "Marte":
		hull = Color("c98262")
		accent = Color("ffbb6a")
		wing = 58.0
	elif origin == "Júpiter":
		hull = Color("b5ac8a")
		accent = Color("ffe4a0")
		wing = 84.0
	elif origin == "Desconhecida":
		hull = Color("958dbd")
		accent = Color("c2a0ff")
		wing = 78.0
	if elite:
		accent = Color("ffce70")
	# Sombra elíptica mantém a nave ancorada visualmente na doca.
	draw_set_transform(Vector2(0, FOOT_Y + altitude - compression + 2.0), 0.0, Vector2(1.0, 0.16))
	draw_circle(Vector2.ZERO, 116.0, Color(0.0, 0.0, 0.0, 0.22))
	draw_set_transform(Vector2.ZERO)
	draw_landing_gear()
	# Asas têm silhuetas distintas para cada origem.
	for side in [-1.0, 1.0]:
		plate([Vector2(-62, side * 20), Vector2(-90, side * wing), Vector2(-22, side * (wing - 8)), Vector2(36, side * 20)], hull.darkened(0.32))
		plate([Vector2(-64, side * 29), Vector2(-77, side * (wing - 9)), Vector2(-30, side * (wing - 16)), Vector2(8, side * 27)], hull.darkened(0.1))
		draw_line(Vector2(-65, side * (wing - 13)), Vector2(-32, side * (wing - 18)), accent, 4.0, true)
		# Motores: cápsula, grelha, chama de várias camadas.
		var y: float = side * 34.0
		plate([Vector2(-92, y - 11), Vector2(-35, y - 11), Vector2(-24, y), Vector2(-35, y + 11), Vector2(-92, y + 11)], Color("34465d"))
		draw_line(Vector2(-85, y - 7), Vector2(-44, y - 7), hull.lightened(0.16), 2.0, true)
		var thrust: float = (55.0 if moving else 10.0) + sin(clock * 24.0 + side) * 4.0
		plate([Vector2(-94, y - 7), Vector2(-94 - thrust, y), Vector2(-94, y + 7)], Color(accent, 0.35))
		draw_colored_polygon(PackedVector2Array([Vector2(-95, y - 4), Vector2(-95 - thrust * 0.72, y), Vector2(-95, y + 4)]), accent)
		lamp(Vector2(-94, y), accent, 3.0)
		for vent in range(4):
			draw_line(Vector2(-74 + vent * 7, y - 4), Vector2(-74 + vent * 7, y + 5), Color("132335"), 2.0)
		lamp(Vector2(-79, side * (wing - 4)), Color("ff6a75") if side < 0 else Color("68efba"), 2.3 + 0.6 * sin(clock * 3.0))
	# Fuselagem: contorno, blindagem inferior e plano iluminado.
	plate([Vector2(-91, -22), Vector2(-63, -34), Vector2(38, -27), Vector2(112, 0), Vector2(38, 29), Vector2(-63, 34), Vector2(-91, 22)], Color("233448"))
	plate([Vector2(-83, -20), Vector2(-58, -29), Vector2(37, -23), Vector2(105, -1), Vector2(35, 8), Vector2(-66, 9)], hull)
	plate([Vector2(-66, 9), Vector2(35, 8), Vector2(105, -1), Vector2(36, 24), Vector2(-60, 28), Vector2(-83, 18)], hull.darkened(0.28))
	draw_line(Vector2(-54, -26), Vector2(35, -21), hull.lightened(0.4), 2.0, true)
	# Junções rebaixadas e riscos acompanham a curvatura do casco.
	for i in range(4):
		var x := -49 + i * 23
		draw_line(Vector2(x,11),Vector2(x+5,22),hull.darkened(0.5),1,true)
		draw_line(Vector2(x+1,11),Vector2(x+6,21),hull.lightened(0.03),1,true)
		draw_line(Vector2(x+8,16),Vector2(x+13,15),hull.lightened(0.15),0.8,true)
	if service_light:
		lamp(Vector2(54,16),Color("#ffc66c"),3.5)
	# Cabine com moldura, vidro escuro e reflexo.
	plate([Vector2(19, -20), Vector2(52, -15), Vector2(82, -2), Vector2(43, 10), Vector2(17, 6)], Color("14283e"))
	plate([Vector2(24, -15), Vector2(49, -11), Vector2(70, -2), Vector2(42, 5), Vector2(24, 2)], accent.darkened(0.4))
	draw_line(Vector2(29, -12), Vector2(46, -9), accent.lightened(0.45), 3.0, true)
	draw_line(Vector2(43, -11), Vector2(48, 3), Color("233b51"), 2.0, true)
	# Painéis de manutenção, rebites e faixa de identificação.
	draw_style_box(panel_style(hull.darkened(0.18)), Rect2(-54, -19, 47, 34))
	for x in [-48.0, -14.0]:
		for y in [-13.0, 9.0]:
			draw_circle(Vector2(x, y), 1.5, Color("d2e0e8"))
	draw_rect(Rect2(-42, -7, 26, 4), accent)
	draw_rect(Rect2(-42, 0, 18, 2), hull.darkened(0.5))
	if origin == "Júpiter":
		for x in [-45.0, -16.0]:
			draw_style_box(panel_style(Color("675f4d")), Rect2(x, 38, 23, 24))
	if origin == "Desconhecida":
		draw_arc(Vector2(-27, -1), 22.0, clock, clock + PI * 1.5, 24, accent, 2.0, true)
	match ship_class:
		"Cargueiro":
			for i in range(3):
				var x := -63 + i * 22
				draw_rect(Rect2(x, -20, 19, 24), Color("c38753"))
				draw_rect(Rect2(x + 4, -20, 3, 24), Color("6f534c"))
		"Resgate":
			draw_rect(Rect2(-47, -14, 24, 24), Color("e9efed"))
			draw_rect(Rect2(-38, -11, 6, 18), Color("d65760"))
			draw_rect(Rect2(-44, -5, 18, 6), Color("d65760"))
		"Pesquisa":
			draw_line(Vector2(-42, -23), Vector2(-50, -44), Color("d0dce4"), 3)
			draw_arc(Vector2(-49, -50), 14, 0.1, PI, 18, Color("a9cbd6"), 4)
			lamp(Vector2(-50, -50), Color("8bf2ff"), 2)
	# Porta de abastecimento e indicador de carga integrado à nave.
	draw_circle(Vector2(0, 22), 9.0, Color("142335"))
	draw_arc(Vector2(0, 22), 7.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(fill, 0.01, 1.0), 32, accent, 2.5, true)
	lamp(Vector2(0, 22), accent if pumping else Color("728399"), 3.0)
	if pumping:
		lamp(Vector2(-5, -24), Color("77ffc8"), 2.0 + sin(clock * 7.0) * 0.6)
	if elite:
		plate([Vector2(-7, -12), Vector2(0, -19), Vector2(7, -12), Vector2(0, -5)], accent)

func panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("34465c")
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	return style
