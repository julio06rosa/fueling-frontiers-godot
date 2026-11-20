extends Control

signal changed
signal finished
signal closed
var kind := ""
var target := 8
var amount := 2
var ring := 0
var feedback := ""
var buttons: Array[Button] = []
const RINGS := [16, 20, 24]
const INK := Color("#112230")
const METAL := Color("#7692a0")
const LIGHT := Color("#e9f0ef")
const AMBER := Color("#ffbf69")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for i in range(4):
		var button := Button.new()
		button.position = Vector2(376 + i * 135, 488)
		button.size = Vector2(124, 45)
		button.pressed.connect(operate.bind(i))
		add_child(button)
		buttons.append(button)
	hide()

func present(job: String, spec: int, level: int, selection: int) -> void:
	kind = job
	target = spec
	amount = level
	ring = selection
	feedback = ""
	var captions := ["Retirar 250 mL", "Dosar 250 mL", "Fechar tampa", "Voltar"] if kind == "oil" else ["‹ Anterior", "Próximo ›", "Encaixar", "Voltar"]
	for i in range(4):
		buttons[i].text = captions[i]
	show()
	buttons[1].grab_focus()
	queue_redraw()

func operate(index: int) -> void:
	if not visible:
		return
	if index == 3:
		closed.emit()
		return
	feedback = ""
	if index == 2:
		if (kind == "oil" and amount == target) or (kind == "seal" and RINGS[ring] == target * 2):
			finished.emit()
			return
		if kind == "oil":
			feedback = "O nível ainda está abaixo da marca." if amount < target else "O nível passou da marca. Retire óleo."
		else:
			feedback = "O anel ficou solto no alojamento." if RINGS[ring] < target * 2 else "O anel é grande demais para o alojamento."
	else:
		var step := -1 if index == 0 else 1
		if kind == "oil":
			amount = clampi(amount + step, 0, 12)
		else:
			ring = posmod(ring + step, RINGS.size())
		changed.emit()
	SoundManager.play_click()
	queue_redraw()

func legend(x: int, y: int, words: String, size_px: int, tint: Color = LIGHT) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(x, y), words, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, tint)

func litres(steps: int) -> String:
	return ("%.2f L" % (steps * 0.25)).replace(".", ",")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#07101bdc"))
	draw_rect(Rect2(346, 148, 588, 414), INK)
	draw_rect(Rect2(346, 148, 588, 414), METAL, false, 2)
	for x in [357, 923]:
		for y in [159, 551]:
			draw_circle(Vector2(x,y), 3, METAL)
	legend(376,188,"ESCOTILHA DE SERVIÇO   /   MOTOR AUXILIAR",14,METAL)
	if kind == "oil":
		legend(376,228,"Dosador de óleo",30)
		draw_rect(Rect2(402,260,125,151), METAL)
		draw_rect(Rect2(408,266,113,139), Color("#081723"))
		var h := amount * 11.0
		draw_rect(Rect2(408,403-h,113,h), Color("#ca803c"))
		for i in range(13):
			draw_line(Vector2(506,403-i*11),Vector2(520,403-i*11),LIGHT if i%4==0 else METAL,1.5)
		var y := 403 - target * 11
		draw_line(Vector2(397,y),Vector2(535,y),AMBER,2)
		legend(569,296,"Nível no visor   " + litres(amount),22)
		legend(569,335,"Marca de serviço   " + litres(target),19,AMBER)
		legend(569,379,"Cada dose move 250 mL.",17,METAL)
	else:
		legend(376,228,"Anel de vedação",30)
		var socket := Vector2(463,331)
		var tray := Vector2(727,331)
		draw_circle(socket,target * 4.0 + 13, METAL,true,-1,true)
		draw_circle(socket,target * 4.0, Color("#09141c"),true,-1,true)
		draw_line(socket,socket+Vector2(target*4,0),AMBER,2)
		draw_circle(socket,3,AMBER)
		draw_arc(tray, RINGS[ring]*2.0,0,TAU,64,Color("#cc8560"),8,true)
		legend(393,415,"Raio   %d mm" % target,20,AMBER)
		legend(635,415,"Diâmetro   %d mm" % RINGS[ring],20)
	legend(376,466,feedback if feedback != "" else ("Ajuste o nível e feche a tampa." if kind == "oil" else "Escolha o anel que encaixa no alojamento."),16)
