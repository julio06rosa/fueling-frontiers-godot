extends Control

# Local coordinates span the exterior opening, from the lintel to the deck.
const SPAN := 1280.0
const TRAVEL := 380.0
const SLAT_HEIGHT := 38
const GUIDE := 16.0

var curtain := Node2D.new()
var frame := Node2D.new()

func _ready() -> void:
	position = Vector2(0, 100)
	size = Vector2(SPAN, TRAVEL)
	z_as_relative = false
	z_index = -4
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	curtain.draw.connect(_draw_curtain)
	frame.draw.connect(_draw_frame)
	add_child(curtain)
	add_child(frame)
	set_closure(0.0)

func set_closure(fraction: float) -> void:
	curtain.position.y = roundf(lerpf(-TRAVEL, 0.0, clampf(fraction, 0.0, 1.0)))

func _draw_curtain() -> void:
	# The slats move together. Their joints and fasteners keep their dimensions in motion.
	curtain.draw_rect(Rect2(0, 0, SPAN, TRAVEL), Color("17252c"))
	for row in range(10):
		var y := float(row * SLAT_HEIGHT)
		var face := Color("40545d") if row % 2 == 0 else Color("3b4e57")
		curtain.draw_rect(Rect2(0, y + 2, SPAN, 31), face)
		curtain.draw_rect(Rect2(0, y + 2, SPAN, 2), Color("758484"))
		curtain.draw_rect(Rect2(0, y + 27, SPAN, 6), face.darkened(0.19))
		for column in range(4):
			var x := 143.0 + column * 300.0 + (85.0 if row % 2 else 0.0)
			curtain.draw_line(Vector2(x, y + 5), Vector2(x, y + 26), Color("2e4049"), 2)
			curtain.draw_circle(Vector2(x - 7, y + 10), 2, Color("86918e"))
			curtain.draw_circle(Vector2(x + 7, y + 21), 2, Color("293b44"))
	# Reinforced leading bar with two worn ochre safety markings and a rubber seal.
	curtain.draw_rect(Rect2(0, TRAVEL - 22, SPAN, 17), Color("293941"))
	curtain.draw_rect(Rect2(0, TRAVEL - 23, SPAN, 2), Color("82908e"))
	for start in [88, 1112]:
		for stripe in range(4):
			var p := Vector2(start + stripe * 20, TRAVEL - 18)
			curtain.draw_colored_polygon(PackedVector2Array([
				p, p + Vector2(12, 0), p + Vector2(4, 11), p + Vector2(-8, 11)
			]), Color("c79555"))
	curtain.draw_rect(Rect2(0, TRAVEL - 5, SPAN, 5), Color("131f24"))

func _draw_frame() -> void:
	for x in [0.0, SPAN - GUIDE]:
		frame.draw_rect(Rect2(x, 0, GUIDE, TRAVEL), Color("24343c"))
		frame.draw_rect(Rect2(x + 5, 0, 4, TRAVEL), Color("677678"))
		for y in range(32, int(TRAVEL), 76):
			frame.draw_circle(Vector2(x + 7, y), 2.5, Color("a0a59a"))
	frame.draw_rect(Rect2(0, 0, SPAN, 10), Color("293941"))
	frame.draw_rect(Rect2(0, 1, SPAN, 2), Color("84908c"))
	frame.draw_rect(Rect2(0, 10, SPAN, 3), Color(0.04, 0.07, 0.09, 0.6))
