extends "res://Player.gd"

# Mantém movimento, colisão, sons e duração das ações do personagem original.
var visual_clock: float = 0.0
var body_offset := Vector2.ZERO
var body_tilt: float = 0.0
var mirror: float = 1.0
var suit := Color("e89b58")
var ink := Color("15283a")

func _process(delta):
	visual_clock += delta
	queue_redraw()

func panel(rect: Rect2, color: Color, radius: int = 3):
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = ink
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	draw_style_box(style, rect)

func body_transform():
	draw_set_transform(body_offset, body_tilt, Vector2(mirror, 1))

func limb(anchor: Vector2, angle: float, length: float, arm: bool, front: bool):
	var transformed: Vector2 = body_offset + Vector2(anchor.x * mirror, anchor.y).rotated(body_tilt)
	draw_set_transform(transformed, body_tilt + angle * mirror, Vector2(mirror, 1))
	var cloth: Color = suit if arm else Color("425d76")
	if not front:
		cloth = cloth.darkened(0.23)
	panel(Rect2(-4.5, -2, 9, length), cloth, 4)
	# Cotoveleira ou joelheira e faixa refletiva.
	panel(Rect2(-5, length * 0.45, 10, 5), Color("274252"), 2)
	draw_line(Vector2(-3, 1), Vector2(-3, length * 0.4), cloth.lightened(0.3), 1.5, true)
	if arm:
		draw_rect(Rect2(-4, length - 4, 8, 2), Color("f8ddb1"))
		panel(Rect2(-4.5, length - 1, 9, 7), Color("203649"), 3)
	else:
		panel(Rect2(-5, length - 2, 14, 7), Color("182b3e"), 2)
		draw_line(Vector2(-4, length + 4), Vector2(8, length + 4), Color("8496a4"), 1.0)
	body_transform()

func _draw():
	mirror = 1.0 if facing_right else -1.0
	var stride: float = sin(walk_cycle)
	var leg_swing: float = 0.0
	var arm_swing: float = 0.06
	var front_arm: float = -0.12
	var bob: float = sin(visual_clock * 2.3) * 0.6
	body_tilt = 0.0
	if current_anim == "walk":
		leg_swing = stride * 0.48
		arm_swing = stride * 0.4
		front_arm = -arm_swing
		bob = -abs(stride) * 1.5
	elif current_anim == "interact":
		front_arm = -1.25 + sin(visual_clock * 10.0) * 0.06
		body_tilt = 0.035 * mirror
	elif current_anim == "celebrate":
		front_arm = -2.5 + sin(visual_clock * 10.0) * 0.15
		arm_swing = 2.5 - sin(visual_clock * 10.0) * 0.15
		bob = -abs(sin(visual_clock * 9.0)) * 5.0
	elif current_anim == "sad":
		front_arm = -2.5
		arm_swing = 0.22
		bob = 2.0
		body_tilt = 0.07 * mirror
	body_offset = Vector2(0, bob)
	# Sombra no piso mantém a leitura de contato durante os saltos.
	draw_set_transform(Vector2(0, 3), 0, Vector2(1, 0.2))
	draw_circle(Vector2.ZERO, 18, Color(0, 0, 0, 0.25))
	body_transform()
	limb(Vector2(-6, -18), leg_swing, 17, false, false)
	# Mochila de suporte de vida com reservatório e iluminação de estado.
	panel(Rect2(-21, -46, 13, 27), Color("344b60"), 4)
	panel(Rect2(-23, -42, 6, 19), Color("7a91a2"), 3)
	draw_rect(Rect2(-20, -38, 2, 8), Color("78d9d1"))
	limb(Vector2(-12, -42), arm_swing, 18, true, false)
	# Macacão laranja, colete e costuras.
	panel(Rect2(-12, -46, 25, 30), suit, 6)
	panel(Rect2(-8, -43, 17, 17), Color("cfdfdf"), 3)
	panel(Rect2(-5, -39, 12, 10), Color("203d51"), 2)
	draw_rect(Rect2(-3, -37, 6, 2), Color("6be8d0"))
	draw_circle(Vector2(4, -32), 1.2, Color("ffc572"))
	draw_line(Vector2(-9, -27), Vector2(-9, -20), Color("ffd3a0"), 1.5, true)
	panel(Rect2(-13, -21, 27, 6), Color("263d52"), 2)
	panel(Rect2(-2, -21, 6, 6), Color("b6c8d0"), 1)
	panel(Rect2(9, -25, 7, 11), Color("435d70"), 2)
	limb(Vector2(6, -18), -leg_swing, 17, false, true)
	# Capacete com aro duplo, vidro, reflexo e rosto visível.
	panel(Rect2(-10, -50, 22, 6), Color("748fa0"), 2)
	draw_circle(Vector2(1, -59), 15.5, ink)
	draw_circle(Vector2(1, -59), 14, Color("d2e0e0"))
	draw_circle(Vector2(3, -59), 11.7, Color("203d54"))
	draw_circle(Vector2(4, -58), 9.5, Color("346377"))
	# A expressão acompanha o resultado do abastecimento.
	draw_circle(Vector2(4, -57), 6.8, Color("eab38c"))
	draw_arc(Vector2(3, -60), 6, PI, TAU, 14, Color("594035"), 4.0, true)
	if current_anim == "celebrate":
		draw_arc(Vector2(7, -58), 1.8, PI, TAU, 8, ink, 1.3, true)
		draw_arc(Vector2(6, -55), 2.4, 0.0, PI, 10, ink, 1.1, true)
	elif current_anim == "sad":
		draw_line(Vector2(5, -57), Vector2(8, -56), ink, 1.3, true)
		draw_arc(Vector2(6, -52), 2, PI, TAU, 8, ink, 1.0, true)
	else:
		if fmod(visual_clock, 4.7) < 0.15:
			draw_line(Vector2(5, -58), Vector2(8, -58), ink, 1.2)
		else:
			draw_circle(Vector2(7, -58), 1.3, ink)
		draw_line(Vector2(6, -53), Vector2(8, -53), ink, 1.0)
	draw_arc(Vector2(3, -59), 10, 3.5, 4.65, 14, Color(0.7, 1, 1, 0.7), 2.0, true)
	panel(Rect2(-15, -62, 6, 9), Color("687f92"), 2)
	draw_circle(Vector2(-12, -58), 1.5, Color("71e3d6"))
	limb(Vector2(12, -41), front_arm, 18, true, true)
	# Pequeno painel holográfico durante a interação.
	if current_anim == "interact":
		panel(Rect2(26, -57, 20, 15), Color(0.08, 0.45, 0.55, 0.65), 2)
		for i in range(3):
			draw_line(Vector2(29, -53 + i * 4), Vector2(40 - i * 2, -53 + i * 4), Color("85eddf"), 1.0)
	draw_set_transform(Vector2.ZERO)
