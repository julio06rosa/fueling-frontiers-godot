extends Node2D

var far_ridge := PackedVector2Array([Vector2(0,315),Vector2(89,308),Vector2(154,314),Vector2(260,282),Vector2(320,280),Vector2(405,306),Vector2(475,294),Vector2(544,260),Vector2(572,264),Vector2(639,296),Vector2(721,284),Vector2(818,243),Vector2(852,244),Vector2(925,281),Vector2(1065,262),Vector2(1190,284),Vector2(1280,268),Vector2(1280,480),Vector2(0,480)])
var near_ridge := PackedVector2Array([Vector2(0,342),Vector2(117,321),Vector2(197,330),Vector2(291,305),Vector2(360,317),Vector2(417,312),Vector2(490,327),Vector2(590,310),Vector2(655,317),Vector2(714,299),Vector2(784,301),Vector2(830,318),Vector2(913,302),Vector2(988,320),Vector2(1131,289),Vector2(1280,315),Vector2(1280,480),Vector2(0,480)])
func _draw():
	# Relevo exterior visto pelo vão da comporta, com luz rasante e névoa no horizonte.
	var dusk := PackedColorArray([Color("#111e31"),Color("#111e31"),Color("#886152"),Color("#886152")])
	draw_polygon(PackedVector2Array([Vector2(0,100),Vector2(1280,100),Vector2(1280,386),Vector2(0,386)]),dusk)
	draw_circle(Vector2(803,228),24,Color("#e9b18a13"),true,-1,true)
	draw_circle(Vector2(803,228),12,Color("#dcb197"),true,-1,true)
	draw_colored_polygon(far_ridge,Color("#68535a"))
	draw_colored_polygon(PackedVector2Array([Vector2(544,260),Vector2(572,264),Vector2(639,296),Vector2(597,287)]),Color("#89695f"))
	draw_colored_polygon(PackedVector2Array([Vector2(818,243),Vector2(852,244),Vector2(925,281),Vector2(867,266)]),Color("#987469"))
	draw_colored_polygon(near_ridge,Color("#503e42"))
	for i in range(17):
		var x := i*79
		var y := 337+(i*13)%37
		draw_line(Vector2(x,y),Vector2(x+16+i%4*9,y-2),Color("#70534d"),1,true)
