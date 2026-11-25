extends Control

var card := Panel.new()
var heading := Label.new()
var message := Label.new()
var target := Rect2()
var current_step := ""

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("122c38")
	style.border_color = Color("79d9ca")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 5
	card.add_theme_stylebox_override("panel", style)
	add_child(card)
	heading.position = Vector2(14, 9)
	heading.add_theme_font_size_override("font_size", 16)
	heading.add_theme_color_override("font_color", Color("9de8d9"))
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(heading)
	message.position = Vector2(14, 34)
	message.add_theme_font_size_override("font_size", 15)
	message.add_theme_color_override("font_color", Color("f0f4ed"))
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(message)
	hide()

func present(step: String, title: String, text: String, area: Rect2, focus: Rect2) -> void:
	current_step = step
	card.position = area.position
	card.size = area.size
	heading.size = Vector2(area.size.x - 28, 23)
	heading.text = title
	message.size = Vector2(area.size.x - 28, area.size.y - 44)
	message.text = text
	target = focus
	show()
	queue_redraw()

func _draw() -> void:
	if not visible:
		return
	# A linha termina na borda do alvo e permanece atrás do cartão.
	var box := Rect2(card.position, card.size)
	var center := target.get_center()
	var edge := center.clamp(box.position, box.end)
	var end := edge.clamp(target.position, target.end)
	var direction := (end - edge).normalized()
	var normal := Vector2(-direction.y, direction.x)
	draw_line(edge, end, Color("79d9ca"), 2, true)
	draw_colored_polygon(PackedVector2Array([edge - normal * 6, edge + normal * 6, edge + direction * 14]), Color("79d9ca"))
	draw_circle(end, 4, Color("a9f4df"))
	draw_rect(target.grow(4), Color(0.48, 0.85, 0.79, 0.08))
	draw_rect(target.grow(4), Color("79d9ca"), false, 2, true)
