extends Node2D

# The origin is the grip; the coupling face is 18 units ahead of the glove.
const TIP := 18.0

func _draw() -> void:
	var handle := PackedVector2Array([Vector2(-8,-4),Vector2(5,-4),Vector2(7,1),Vector2(-1,7),Vector2(-8,7)])
	draw_colored_polygon(handle, Color("172a33"))
	draw_polyline(handle + PackedVector2Array([handle[0]]), Color("7a8b86"), 1.7, true)
	draw_line(Vector2(-5,4),Vector2(2,0),Color("bd884a"),2.5,true)
	draw_rect(Rect2(-13,-5,18,6),Color("d8964d"))
	draw_rect(Rect2(-16,-5,4,7),Color("35434a"))
	draw_rect(Rect2(5,-3,11,5),Color("b9c4bd"))
	draw_rect(Rect2(12,-5,4,9),Color("536972"))
	draw_line(Vector2(TIP,-3),Vector2(TIP,3),Color("d5e4d9"),2,true)
