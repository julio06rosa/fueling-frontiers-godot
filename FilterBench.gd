extends ColorRect

signal command(action: String, part: int)

const FilterArt = preload("res://FilterAssembly.gd")
var card := Panel.new()
var drawing := FilterArt.new()
var title := Label.new()
var hint := Label.new()
var reading := Label.new()
var keys: Array[Button] = []
var mode := ""
var complete := false
var last_zone := -1
var dragging := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color = Color(0.025,0.042,0.062,0.76)
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(card)
	card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	card.offset_left = -318
	card.offset_right = 318
	card.offset_top = -190
	card.offset_bottom = 190
	var skin := StyleBoxFlat.new()
	skin.bg_color = Color("142734")
	skin.border_color = Color("64787a")
	skin.set_border_width_all(2)
	skin.set_corner_radius_all(12)
	card.add_theme_stylebox_override("panel",skin)
	add_label(Label.new(),"DOCA 01     /     MANUTENÇÃO",Vector2(28,17),14,Color("9fc4be"))
	add_label(title,"",Vector2(28,44),27,Color("ebefec"))
	add_label(hint,"",Vector2(28,92),17,Color("d3dedb"))
	var well := ColorRect.new()
	well.position = Vector2(28,130)
	well.size = Vector2(580,150)
	well.color = Color("0c1b27")
	well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(well)
	card.add_child(drawing)
	drawing.position = Vector2(315,204)
	drawing.scale = Vector2.ONE*2.45
	card.gui_input.connect(_card_input)
	add_label(reading,"",Vector2(28,345),15,Color("a2c1bc"))
	for i in range(3):
		var button := make_button("",Vector2(28+i*195,293),Vector2(187,39))
		button.pressed.connect(_action_button.bind(i))
		keys.append(button)
	var close := make_button("Voltar  [Esc]",Vector2(480,22),Vector2(128,35))
	close.pressed.connect(func(): command.emit("close",0))
	hide()

func make_button(caption: String, pos: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.text = caption
	button.position = pos
	button.size = dimensions
	button.focus_mode = Control.FOCUS_NONE
	card.add_child(button)
	return button

func add_label(label: Label, caption: String, pos: Vector2, font_size: int, tint: Color) -> void:
	label.text = caption
	label.position = pos
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",tint)
	card.add_child(label)

func present(failure: String, fixed: bool, remaining: int, collar: int) -> void:
	mode = failure
	complete = fixed or mode not in ["Filtro com poeira","Pressão oscilante"]
	var dust := mode == "Filtro com poeira"
	for i in range(3):
		keys[i].visible = not complete
		keys[i].disabled = false
	if complete:
		title.text = "Filtro em operação"
		hint.text = "Aletas livres e pressão estável. Volte à doca para continuar."
		reading.text = "Circuito em espera     ·     F ou Esc para voltar"
	elif dust:
		title.text = "Filtro obstruído"
		hint.text = "Arraste o mouse pelas três grades ou use as teclas 1, 2 e 3."
		for i in range(3):
			keys[i].text = "Limpar grade %d" % (i+1)
			keys[i].disabled = (remaining & (1 << i)) == 0
		reading.text = "Filtro em inspeção     ·     Tempo e bomba suspensos"
	else:
		title.text = "Anel de vedação solto"
		hint.text = "Gire o anel até alinhar o traço âmbar com a marca branca."
		keys[0].text = "Girar  [←]"
		keys[1].text = "Girar  [→]"
		keys[2].text = "Fixar anel  [F]"
		keys[2].disabled = collar != 0
		reading.text = "Marcas alinhadas. Fixe o anel." if collar == 0 else "Vazamento na saída     ·     Tempo e bomba suspensos"

func _action_button(index: int) -> void:
	if complete:
		return
	if mode == "Filtro com poeira":
		command.emit("brush",index)
	elif index == 2:
		command.emit("lock",0)
	else:
		command.emit("turn",-1 if index == 0 else 1)

func _card_input(event: InputEvent) -> void:
	if complete or mode != "Filtro com poeira":
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		last_zone = -1
	if event is InputEventMouseMotion:
		dragging = (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0
	if not dragging or not (event is InputEventMouseMotion or event is InputEventMouseButton):
		return
	var p: Vector2 = (event.position - drawing.position)/drawing.scale
	if absf(p.y) > 16:
		return
	for i in range(3):
		if absf(p.x - FilterArt.CENTRES[i]) <= 11 and last_zone != i:
			last_zone = i
			command.emit("brush",i)
			accept_event()
			break

func keyboard(code: Key) -> void:
	if code == KEY_ESCAPE or (complete and code in [KEY_F,KEY_ENTER]):
		command.emit("close",0)
	elif not complete:
		if mode == "Filtro com poeira" and code in [KEY_1,KEY_2,KEY_3]:
			command.emit("brush",code-KEY_1)
		elif mode == "Pressão oscilante":
			if code in [KEY_LEFT,KEY_RIGHT]:
				command.emit("turn",-1 if code == KEY_LEFT else 1)
			elif code in [KEY_F,KEY_ENTER]:
				command.emit("lock",0)
